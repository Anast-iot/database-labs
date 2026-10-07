USE lab2_variant72;

SELECT model, type, price 
FROM Printer 
WHERE price < 300 
ORDER BY type DESC;

SELECT name 
FROM Battles 
WHERE name LIKE '% %' 
  AND name NOT LIKE '% % %' 
  AND name NOT LIKE '%c';
  
  
SELECT s.name, c.country 
FROM Ships s
JOIN Classes c ON s.class = c.class;

SELECT DISTINCT maker 
FROM Product 
WHERE type = 'PC' 
  AND maker != SOME (
      SELECT maker 
      FROM Product 
      WHERE type = 'Laptop'
  )
  AND maker NOT IN (
      SELECT maker 
      FROM Product 
      WHERE type = 'Laptop'
  );
  
  SELECT s.name, s.launched, c.displacement 
FROM Ships s
JOIN Classes c ON s.class = c.class
WHERE c.type = 'bb' 
  AND s.launched >= 1922 
  AND c.displacement > 35000;
  
SELECT 
    CONCAT('код: ', code) AS code_info,
    CONCAT('модель: ', model) AS model_info,
    CONCAT('швидкість: ', speed) AS speed_info,
    CONCAT('пам''ять: ', ram) AS ram_info,
    CONCAT('диск: ', hd) AS hd_info,
    CONCAT('привід: ', cd) AS cd_info,
    CONCAT('ціна: ', price) AS price_info
FROM PC;

SELECT o.battle, c.country, COUNT(o.ship) AS num_ships 
FROM Outcomes o
JOIN Ships s ON o.ship = s.name
JOIN Classes c ON s.class = c.class
GROUP BY o.battle, c.country
HAVING COUNT(o.ship) >= 2;

SELECT DISTINCT p.maker,
    (SELECT AVG(l.screen) 
     FROM Laptop l 
     JOIN Product p2 ON l.model = p2.model 
     WHERE p2.maker = p.maker) AS avg_screen
FROM Product p
WHERE p.maker IN (SELECT maker FROM Product WHERE type = 'Laptop');

SELECT 
    s.name, 
    c.numGuns, 
    c.bore, 
    c.displacement, 
    c.type, 
    c.country, 
    s.launched, 
    s.class
FROM Ships s
JOIN Classes c ON s.class = c.class
WHERE (
    CASE WHEN c.numGuns = 9 THEN 1 ELSE 0 END +
    CASE WHEN c.bore = 16 THEN 1 ELSE 0 END +
    CASE WHEN c.displacement = 46000 THEN 1 ELSE 0 END +
    CASE WHEN c.type = 'bb' THEN 1 ELSE 0 END +
    CASE WHEN c.country = 'Japan' THEN 1 ELSE 0 END +
    CASE WHEN s.launched = 1916 THEN 1 ELSE 0 END +
    CASE WHEN s.class = 'Revenge' THEN 1 ELSE 0 END
) >= 3;

SELECT all_ships.class
FROM (
    SELECT name AS ship_name, class 
    FROM Ships
    UNION
    SELECT o.ship AS ship_name, o.ship AS class
    FROM Outcomes o
    WHERE NOT EXISTS (SELECT 1 FROM Ships s WHERE s.name = o.ship)
      AND EXISTS (SELECT 1 FROM Classes c WHERE c.class = o.ship)
) AS all_ships
GROUP BY all_ships.class
HAVING COUNT(all_ships.ship_name) = 1;