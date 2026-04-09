
CREATE TABLE zepto(
sku_id SERIAL PRIMARY KEY,
category VARCHAR(50),
name VARCHAR(120),
mrp NUMERIC(8, 2),
discountPercent NUMERIC(5, 2),
availableQuantity INTEGER,
discountedSellingPrice NUMERIC(8, 2),
weightInGms INTEGER,
outOfStock BOOLEAN,
quantity INTEGER
);  

SELECT COUNT(*) FROM zepto;

SELECT * FROM zepto;

-- DATA CLEANING

SELECT * FROM zepto
WHERE name IS NULL
OR
category IS NULL
OR
mrp IS NULL
OR
discountpercent IS NULL
OR
availablequantity IS NULL
OR
discountedsellingprice IS NULL
OR
weightingms IS NULL
OR
outofstock IS NULL
OR
quantity IS NULL


-- Invalid pricing check
SELECT * 
FROM zepto
WHERE discountedSellingPrice > mrp;

SELECT * 
FROM zepto
WHERE discountedSellingPrice <=0 OR mrp <= 0

UPDATE zepto
SET mrp = mrp / 100.0,
    discountedsellingprice = discountedsellingprice / 100.0;

SELECT * FROM zepto
LIMIT 10;

UPDATE zepto
SET mrp = mrp * 100.0,
    discountedsellingprice = discountedsellingprice * 100.0;

SELECT * 
FROM zepto
WHERE outofstock IS TRUE AND availablequantity > 0;

SELECT * 
FROM zepto
WHERE outofstock IS FALSE AND availablequantity <= 0;

SELECT * 
FROM zepto
WHERE weightingms <= 0;

CREATE VIEW zepto_clean AS
SELECT *
FROM zepto
WHERE mrp > 0
AND discountedSellingPrice > 0
AND weightInGms > 0;

-- EDA (Exployratory data analysis)

-- product analysis

SELECT DISTINCT(category) AS total_category
FROM zepto_clean;

SELECT category, COUNT(*) AS total_products
FROM zepto_clean
GROUP BY category
ORDER BY total_products DESC;

SELECT 
MIN(weightingms) AS min_weight,
MAX(weightingms) AS max_weight,
AVG(weightingms) AS avg_weight
FROM zepto_clean;

SELECT name
FROM zepto_clean
WHERE weightingms > 8000
GROUP BY name;

SELECT category,
AVG(weightingms) AS avg_weight
FROM zepto_clean
GROUP BY category
ORDER BY avg_weight DESC
LIMIT 10;

SELECT category,
AVG(mrp) AS avg_price
FROM zepto_clean
GROUP BY category
ORDER BY avg_price DESC
LIMIT 10;

SELECT category,
AVG(availablequantity) AS avg_quantity
FROM zepto_clean
WHERE outofstock IS FALSE
GROUP BY category
ORDER BY avg_quantity DESC
LIMIT 10;

SELECT 
CORR(discountedsellingprice, discountpercent) AS correlation
FROM zepto_clean;

SELECT category,
AVG(discountPercent) AS avg_discount
FROM zepto_clean
GROUP BY category
ORDER BY avg_discount DESC;

SELECT 
MIN(discountedsellingprice) AS min_price,
MAX(discountedsellingprice) AS max_price,
AVG(discountedsellingprice) AS avg_price
FROM zepto_clean;


SELECT 
CASE 
    WHEN discountedsellingprice < 100 THEN 'Low Price'
    WHEN discountedsellingprice < 500 THEN 'Medium Price'
    ELSE 'High Price'
END AS price_bucket,

AVG(discountPercent) AS avg_discount

FROM zepto_clean
GROUP BY price_bucket;

SELECT 
MIN(availablequantity) AS min_quantity,
MAX(availablequantity) AS max_quantity,
AVG(availablequantity) AS avg_quantity
FROM zepto_clean
WHERE outofstock IS FALSE;


SELECT 
CASE 
    WHEN availablequantity < 2 THEN 'Low Stock'
    WHEN availablequantity < 4 THEN 'Medium Stock'
    ELSE 'High Stock'
END AS stock_category,

AVG(discountPercent) AS avg_discount

FROM zepto_clean
GROUP BY stock_category;


SELECT 
CASE 
    WHEN weightInGms < 500 THEN 'Small'
    WHEN weightInGms < 2000 THEN 'Medium'
    ELSE 'Bulk'
END AS size_category,

AVG(discountPercent) AS avg_discount

FROM zepto_clean
GROUP BY size_category;

SELECT 
CORR(weightInGms, discountpercent) AS correlation
FROM zepto_clean;

-- inventory value analysis 

SELECT category,
SUM(discountedsellingprice * availablequantity) AS inventory_value
FROM zepto_clean
GROUP BY category
ORDER BY inventory_value DESC;

SELECT name, category,
discountedsellingPrice * availablequantity AS potential_revenue
FROM zepto_clean
ORDER BY potential_revenue DESC
LIMIT 10;


SELECT category, SUM(availablequantity)
FROM zepto_clean
GROUP BY category;



WITH product_metrics AS (
    SELECT 
        name,
        category,
        availablequantity,
        discountPercent,
        (discountedsellingprice * availablequantity) AS inventory_value,
        
        -- Tier 1 = Low, Tier 2 = Medium, Tier 3 = High
        NTILE(3) OVER (ORDER BY availablequantity ASC) AS stock_tier, 
        NTILE(3) OVER (ORDER BY discountPercent ASC) AS discount_tier 
    FROM zepto_clean
    WHERE outofstock IS FALSE 
)
SELECT 
    name,
    category,
    availablequantity,
    discountPercent,
    inventory_value,
    CASE 
        WHEN stock_tier = 3 AND discount_tier = 3 THEN 'Critical Risk'
        WHEN stock_tier = 3 AND discount_tier = 2 THEN 'High Risk'
        WHEN (stock_tier = 2 AND discount_tier = 3) OR (stock_tier = 2 AND discount_tier = 2) THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS inventory_risk_level
FROM product_metrics
ORDER BY inventory_value DESC;

-- BUSINESS QUESTIONS

-- Q1. Which categories are suffering the most from being entirely Out of Stock, and how much potential inventory value are we losing because we don't have these items?

SELECT category,
COUNT(*) AS low_stock_products,
SUM(discountedsellingprice * availablequantity) AS potential_loss_value
FROM zepto_clean
WHERE availablequantity <= 1
GROUP BY category
ORDER BY potential_loss_value DESC;

-- Insight:
-- Some categories have many products with very low stock (0–1 units).
-- This means customers may not find what they need, which can lead to lost sales.
-- These categories should be restocked quickly.


-- Q2. Which specific products or categories are heavily discounted (e.g., > 30%) but still have massive amounts of availableQuantity sitting in the warehouse?

SELECT 
category,
SUM(availablequantity) AS total_stock
FROM zepto_clean
WHERE discountPercent > 30
GROUP BY category
ORDER BY total_stock DESC;

-- Insight:
-- There are categories where products have high discounts but still remain in stock in large quantities.
-- This shows that discounts are not helping much in selling these products.
-- It may indicate poor demand or wrong pricing strategy.


-- Q.3 Which categories have a high variety of unique products (breadth) but very low average stock per product (depth)?

SELECT 
category,
COUNT(DISTINCT name) AS unique_products,
AVG(availablequantity) AS avg_stock
FROM zepto_clean
GROUP BY category
ORDER BY unique_products DESC;


-- Insight:
-- Some categories have many different products but very low stock for each item.
-- This means variety is high, but availability is low.
-- It can confuse customers and reduce chances of actual purchase.


-- Q.4 Which items or categories yield the lowest revenue per kilogram?

SELECT 
category,
AVG(discountedsellingprice / (weightingms / 1000.0)) AS value_per_kg
FROM zepto_clean
GROUP BY category
ORDER BY value_per_kg;


-- Insight:
-- Some categories give very low value compared to their weight.
-- These products take more space and delivery effort but generate less revenue.
-- This can increase delivery cost and reduce efficiency.



-- Q.5 What percentage of our total inventory value comes from "Premium" products (MRP > certain threshold) versus "Everyday Value" products?


SELECT 
CASE 
    WHEN mrp > 500 THEN 'Premium'
    ELSE 'Value'
END AS price_segment,
SUM(discountedsellingprice * availablequantity) AS inventory_value
FROM zepto_clean
GROUP BY price_segment;


-- Insight:
-- Most of the inventory value comes from lower-priced (value) products.
-- This shows the platform is more focused on affordable items rather than premium products.



-- Q.6 Is there a relationship between the depth of the discount and the remaining available quantity across different categories? 


SELECT 
CORR(availablequantity, discountpercent) AS correlation
FROM zepto_clean;


SELECT 
category,
AVG(discountpercent) AS avg_discount,
AVG(availablequantity) AS avg_stock
FROM zepto_clean
GROUP BY category
ORDER BY avg_discount DESC;


-- Insight:
-- There is a very weak relationship between discount and stock levels.
-- This means higher discounts are not strongly helping in reducing stock.
-- Overall, discount strategy does not seem very effective in driving sales.


-- Creating the view for Power BI dashboard

CREATE OR REPLACE VIEW powerbi_zepto_master AS
WITH base_metrics AS (
    SELECT 
        sku_id,
        category,
        name,
        -- Converting prices to standard currency (2500 -> 25.00)
        (mrp / 100.0) AS mrp_actual,
        (discountedSellingPrice / 100.0) AS price_actual,
        discountPercent,
        availableQuantity,
        weightInGms,
        outOfStock,
        
        -- Potential Inventory Value (Price * Quantity)
        ((discountedSellingPrice / 100.0) * availableQuantity) AS inventory_value,
        
        -- Value Density (Value per KG)
        -- Calculation: Price / (Grams/1000)
        CASE 
            WHEN weightInGms > 0 THEN (discountedSellingPrice / 100.0) / (weightInGms / 1000.0) 
            ELSE 0 
        END AS value_per_kg,
        
        -- Risk Tiering (Global ranking)
        NTILE(3) OVER (ORDER BY availableQuantity ASC) AS stock_tier, 
        NTILE(3) OVER (ORDER BY discountPercent ASC) AS discount_tier 
    FROM zepto
    WHERE mrp > 0 AND weightInGms > 0
)
SELECT 
    sku_id,
    category,
    name,
    mrp_actual,
    price_actual,
    discountPercent,
    availableQuantity,
    weightInGms,
    outOfStock,
    inventory_value,
    ROUND(CAST(value_per_kg AS NUMERIC), 2) AS value_per_kg,
    
    -- 1. Inventory Risk Level (The logic you defined)
    CASE 
        WHEN stock_tier = 3 AND discount_tier = 3 THEN '1. Critical Risk'
        WHEN stock_tier = 3 AND discount_tier = 2 THEN '2. High Risk'
        WHEN stock_tier = 2 AND (discount_tier = 3 OR discount_tier = 2) THEN '3. Medium Risk'
        ELSE '4. Low Risk'
    END AS inventory_risk_level,
    
    -- 2. Price Segmentation
    CASE 
        WHEN mrp_actual >= 500 THEN 'Premium (>500)'
        WHEN mrp_actual >= 100 THEN 'Mid-Range (100-500)'
        ELSE 'Everyday Value (<100)'
    END AS price_segment,

    -- 3. Stock Status (Useful for filtering Out of Stock)
    CASE 
        WHEN outOfStock = TRUE OR availableQuantity = 0 THEN 'Out of Stock'
        WHEN availableQuantity <= 2 THEN 'Low Stock'
        ELSE 'Healthy Stock'
    END AS stock_status

FROM base_metrics;




