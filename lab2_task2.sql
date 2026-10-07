USE vending_db;

SELECT DISTINCT 
    vm.id AS machine_id, 
    vm.serial_number, 
    vm.model, 
    loc.address, 
    loc.gps_latitude, 
    loc.gps_longitude, 
    rs.refill_date
FROM vending_machines vm
JOIN locations loc ON vm.locations_id = loc.id
JOIN refill_sessions rs ON vm.id = rs.vending_machines_id
WHERE (loc.address LIKE '%Шевченка%' OR (loc.gps_latitude = 49.839683 AND loc.gps_longitude = 24.029717))
  AND rs.refill_date >= NOW() - INTERVAL 3 DAY;
  
SELECT 
    b.brand_name,
    -- 1. Общее количество проданных снеков выбранного бренда за сьогодні
    (SELECT SUM(dsr.total_items_sold)
     FROM daily_sales_reports dsr
     JOIN vending_machines vm ON dsr.vending_machines_id = vm.id
     JOIN machine_slots ms ON vm.id = ms.vending_machines_id
     JOIN products p ON ms.products_id = p.id
     WHERE p.brands_id = b.id 
       AND dsr.report_date = CURDATE()) AS total_snacks_sold_today,

    -- 2. Середня сума інкасацій за сьогодні
    (SELECT AVG(co.amount)
     FROM cash_operations co
     WHERE co.operation_type = 'cash_collection' 
       AND DATE(co.operation_datetime) = CURDATE()) AS avg_collected_cash_today
FROM brands b
LIMIT 1;

SELECT 
    t.id AS technician_id,
    t.full_name,
    COUNT(DISTINCT rs.vending_machines_id) AS machines_serviced_count
FROM technicians t
JOIN refill_sessions rs ON t.id = rs.technicians_id
GROUP BY t.id, t.full_name
HAVING COUNT(DISTINCT rs.vending_machines_id) >= 1;

SELECT 
    p.product_name,
    b.brand_name,
    loc.address AS machine_address,
    vm.serial_number AS machine_serial,
    t.full_name AS technician_name,
    dsr.report_date,
    dsr.total_items_sold
FROM daily_sales_reports dsr
JOIN vending_machines vm ON dsr.vending_machines_id = vm.id
JOIN locations loc ON vm.locations_id = loc.id
JOIN machine_slots ms ON vm.id = ms.vending_machines_id
JOIN products p ON ms.products_id = p.id
JOIN brands b ON p.brands_id = b.id
JOIN refill_sessions rs ON vm.id = rs.vending_machines_id
JOIN technicians t ON rs.technicians_id = t.id;

SELECT 
    vm.id AS machine_id,
    vm.serial_number,
    vm.model,
    loc.address,
    dsr.report_date,
    dsr.total_revenue
FROM vending_machines vm
JOIN locations loc ON vm.locations_id = loc.id
JOIN daily_sales_reports dsr ON vm.id = dsr.vending_machines_id
WHERE dsr.total_revenue = (
    SELECT MAX(total_revenue) 
    FROM daily_sales_reports
);