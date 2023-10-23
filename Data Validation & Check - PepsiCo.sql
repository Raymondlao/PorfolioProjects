SELECT *
FROM pepsico_products

-- Checking for duplicate data
SELECT `Product Name`, COUNT(*) AS Count 
FROM pepsico_products
GROUP BY `Product Name`
HAVING count > 1 

-- Checking for empty values
SELECT *
FROM pepsico_products
WHERE `Year Launched` IS NULL OR `Category` = '' OR `Ownership` IS NULL

-- Calculate and track data quality metrics, such as data completeness or data accuracy
SELECT COUNT(*) AS total_records,
       COUNT(CASE WHEN column IS NULL THEN 1 ELSE NULL END) AS missing_values
FROM pepsico_products

-- Finding potential outliers in a numerical column using aggregate functions
SELECT AVG(sales) AS avg_value, 
       STDDEV(sales) AS std_dev
FROM pepsico_products

