USE ecommerce_analysis;

LOAD DATA LOCAL INFILE 'C:/Users/Nalin Attrey/OneDrive/Pictures/Desktop/E-Commerce-Sales-Customer-Analytics/processed/ecommerce_cleaned.csv.csv'
INTO TABLE ecommerce_sales
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(InvoiceNo, StockCode, Description, Quantity, InvoiceDate, UnitPrice, CustomerID, Country, Revenue);
SELECT COUNT(*) FROM ecommerce_sales;
SELECT * FROM ecommerce_sales LIMIT 10; 
DESCRIBE ecommerce_sales;
SELECT 
    COUNT(*) AS total_rows,
    COUNT(InvoiceNo) AS invoice_count,
    COUNT(StockCode) AS stock_count,
    COUNT(Quantity) AS quantity_count,
    COUNT(InvoiceDate) AS date_count,
    COUNT(UnitPrice) AS price_count,
    COUNT(CustomerID) AS customer_count,
    COUNT(Country) AS country_count,
    COUNT(Revenue) AS revenue_count
FROM ecommerce_sales;   
-- =====================================================
-- SECTION 1: DATASET OVERVIEW
-- =====================================================

-- 1. Date range
SELECT 
    MIN(InvoiceDate) AS first_date,
    MAX(InvoiceDate) AS last_date
FROM ecommerce_sales;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT InvoiceNo) AS unique_invoices,
    COUNT(DISTINCT StockCode) AS unique_products,
    COUNT(DISTINCT CustomerID) AS unique_customers,
    COUNT(DISTINCT Country) AS unique_countries
FROM ecommerce_sales;

SELECT
    COUNT(*) AS total_rows,
    SUM(InvoiceNo IS NULL) AS missing_invoice,
    SUM(StockCode IS NULL) AS missing_stockcode,
    SUM(Description IS NULL) AS missing_description,
    SUM(Quantity IS NULL) AS missing_quantity,
    SUM(InvoiceDate IS NULL) AS missing_date,
    SUM(UnitPrice IS NULL) AS missing_price,
    SUM(CustomerID IS NULL) AS missing_customer,
    SUM(Country IS NULL) AS missing_country,
    SUM(Revenue IS NULL) AS missing_revenue
FROM ecommerce_sales;

SELECT
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    UnitPrice,
    CustomerID,
    Country,
    Revenue,
    COUNT(*) AS duplicate_count
FROM ecommerce_sales
GROUP BY
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    UnitPrice, 
    CustomerID,
    Country,
    Revenue
HAVING COUNT(*) > 1;

SELECT   
    COUNT(*) AS negative_quantity_rows,
    SUM(ABS(Quantity)) AS total_returned_quantity
FROM ecommerce_sales
WHERE Quantity < 0;

SELECT
    COUNT(*) AS invalid_price_rows,
    MIN(UnitPrice) AS minimum_price
FROM ecommerce_sales
WHERE UnitPrice <= 0;

SELECT 
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    UnitPrice,
    CustomerID,
    Country,
    Revenue
FROM ecommerce_sales
WHERE UnitPrice <= 0;

SELECT
    StockCode,
    Description,
    COUNT(*) AS zero_price_rows,
    SUM(Quantity) AS total_quantity,
    SUM(Revenue) AS total_revenue
FROM ecommerce_sales
WHERE UnitPrice = 0
GROUP BY StockCode, Description
ORDER BY zero_price_rows DESC;  

SELECT
    COUNT(*) AS total_rows,
    SUM(
        CASE
            WHEN ABS(Revenue - (Quantity * UnitPrice)) > 0.01
            THEN 1
            ELSE 0
        END
    ) AS revenue_mismatch_rows
FROM ecommerce_sales;
-- calculate renevue
select 
    ROUND(SUM(Revenue),2) as total_revenue
from ecommerce_sales
  where UnitPrice>0;  
  -- total quantity sold
  select 
     sum(Quantity) as total_quantity_sold
	from ecommerce_sales
where UnitPrice>0;
-- Average_order_revenue
SELECT
    ROUND(
        SUM(Revenue) / COUNT(DISTINCT InvoiceNo),
        2
    ) AS average_order_value
FROM ecommerce_sales
WHERE UnitPrice > 0;
        
SELECT
    StockCode,
    Description,
    SUM(Quantity) AS total_quantity_sold,
    ROUND(SUM(Revenue), 2) AS total_revenue
FROM ecommerce_sales
WHERE UnitPrice > 0 
GROUP BY StockCode, Description
ORDER BY total_revenue DESC
LIMIT 10; 

SELECT
    Country,
    ROUND(SUM(Revenue), 2) AS total_revenue
FROM ecommerce_sales
WHERE UnitPrice > 0
GROUP BY Country
ORDER BY total_revenue DESC
LIMIT 10;

SELECT
    YEAR(InvoiceDate) AS year,
    MONTH(InvoiceDate) AS month,
    ROUND(SUM(Revenue), 2) AS monthly_revenue
FROM ecommerce_sales
WHERE UnitPrice > 0
GROUP BY YEAR(InvoiceDate), MONTH(InvoiceDate)
ORDER BY year, month;

-- Top 10 customers by revenue
SELECT
    CustomerID,
    ROUND(SUM(Revenue), 2) AS total_revenue,
    SUM(Quantity) AS total_quantity
FROM ecommerce_sales
WHERE UnitPrice > 0
  AND CustomerID IS NOT NULL
GROUP BY CustomerID
ORDER BY total_revenue DESC
LIMIT 10;

-- Top 10 customers by number of orders
SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    ROUND(SUM(Revenue), 2) AS total_revenue
FROM ecommerce_sales
WHERE UnitPrice > 0
  AND CustomerID IS NOT NULL
GROUP BY CustomerID
ORDER BY total_orders DESC
LIMIT 10; 

SELECT
    customer_type,
    COUNT(*) AS customer_count
FROM (
    SELECT
        CustomerID,
        CASE
            WHEN COUNT(DISTINCT InvoiceNo) > 1 THEN 'Repeat Customer'
            ELSE 'One-Time Customer'
        END AS customer_type
    FROM ecommerce_sales
    WHERE UnitPrice > 0
      AND CustomerID IS NOT NULL
    GROUP BY CustomerID
) AS customer_summary
GROUP BY customer_type;
-- calculate what percentage of customers are repeat customers:
SELECT
    ROUND(
        100.0 * SUM(CASE WHEN customer_type = 'Repeat Customer' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS repeat_purchase_rate
FROM (
    SELECT
        CustomerID,
        CASE
            WHEN COUNT(DISTINCT InvoiceNo) > 1
                THEN 'Repeat Customer'
            ELSE 'One-Time Customer'
        END AS customer_type
    FROM ecommerce_sales
    WHERE UnitPrice > 0
      AND CustomerID IS NOT NULL
    GROUP BY CustomerID
) AS customer_summary;

-- Top 10 customers by revenue
SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    ROUND(SUM(Revenue), 2) AS total_revenue
FROM ecommerce_sales
WHERE UnitPrice > 0
  AND CustomerID IS NOT NULL
GROUP BY CustomerID
ORDER BY total_revenue DESC
LIMIT 10;
-- Top 10 countries by revenue
SELECT
    Country,
    ROUND(SUM(Revenue), 2) AS total_revenue
FROM ecommerce_sales
WHERE UnitPrice > 0
GROUP BY Country
ORDER BY total_revenue DESC
LIMIT 10;
-- Recency
SELECT
    MAX(InvoiceDate) AS last_purchase_date
FROM ecommerce_sales
WHERE UnitPrice > 0
  AND CustomerID IS NOT NULL;
  
  -- RFM Analysis
SELECT
    CustomerID,
    DATEDIFF(
        (SELECT MAX(InvoiceDate)
         FROM ecommerce_sales
         WHERE UnitPrice > 0),
        MAX(InvoiceDate)
    ) AS recency_days,
    COUNT(DISTINCT InvoiceNo) AS frequency,
    ROUND(SUM(Revenue), 2) AS monetary
FROM ecommerce_sales
WHERE UnitPrice > 0
  AND CustomerID IS NOT NULL
GROUP BY CustomerID;
-- RFM Scoring
SELECT
    CustomerID,
    recency_days,
    frequency,
    monetary,

    NTILE(4) OVER (ORDER BY recency_days DESC) AS R_score,
    NTILE(4) OVER (ORDER BY frequency ASC) AS F_score,
    NTILE(4) OVER (ORDER BY monetary ASC) AS M_score

FROM (
    SELECT
        CustomerID,

        DATEDIFF(
            (SELECT MAX(InvoiceDate)
             FROM ecommerce_sales
             WHERE UnitPrice > 0),
            MAX(InvoiceDate)
        ) AS recency_days,

        COUNT(DISTINCT InvoiceNo) AS frequency,

        ROUND(SUM(Revenue), 2) AS monetary

    FROM ecommerce_sales
    WHERE UnitPrice > 0
      AND CustomerID IS NOT NULL

    GROUP BY CustomerID 
) AS rfm;
-- Customer Segmentation based on RFM scores

SELECT
    CustomerID,
    recency_days,
    frequency,
    monetary,
    R_score,
    F_score,
    M_score,

    CASE
        WHEN R_score >= 4 AND F_score >= 4 AND M_score >= 4
            THEN 'High Value Customer'

        WHEN R_score >= 4 AND F_score >= 4
            THEN 'Loyal Customer'

        WHEN R_score >= 4
            THEN 'Recent Customer'

        WHEN R_score <= 2 AND F_score >= 3
            THEN 'At Risk Customer'

        ELSE 'Low Value Customer'
    END AS customer_segment

FROM (
    -- Your RFM scoring query goes here
    SELECT
    CustomerID,
    recency_days,
    frequency,
    monetary,

    NTILE(4) OVER (ORDER BY recency_days DESC) AS R_score,
    NTILE(4) OVER (ORDER BY frequency ASC) AS F_score,
    NTILE(4) OVER (ORDER BY monetary ASC) AS M_score

FROM (
    SELECT
        CustomerID,

        DATEDIFF(
            (SELECT MAX(InvoiceDate)
             FROM ecommerce_sales
             WHERE UnitPrice > 0),
            MAX(InvoiceDate)
        ) AS recency_days,

        COUNT(DISTINCT InvoiceNo) AS frequency,

        ROUND(SUM(Revenue), 2) AS monetary

    FROM ecommerce_sales
    WHERE UnitPrice > 0
      AND CustomerID IS NOT NULL

    GROUP BY CustomerID
) AS rfm
) AS rfm_scores;  
-- Customer segment summary
SELECT
    customer_segment,
    COUNT(*) AS customer_count
FROM (
   
SELECT
    CustomerID,
    recency_days,
    frequency,
    monetary,
    R_score,
    F_score,
    M_score,

    CASE
        WHEN R_score >= 4 AND F_score >= 4 AND M_score >= 4
            THEN 'High Value Customer'

        WHEN R_score >= 4 AND F_score >= 4
            THEN 'Loyal Customer'

        WHEN R_score >= 4
            THEN 'Recent Customer'

        WHEN R_score <= 2 AND F_score >= 3
            THEN 'At Risk Customer'

        ELSE 'Low Value Customer'
    END AS customer_segment

FROM (
    -- Your RFM scoring query goes here
    SELECT
    CustomerID,
    recency_days,
    frequency,
    monetary,

    NTILE(4) OVER (ORDER BY recency_days DESC) AS R_score,
    NTILE(4) OVER (ORDER BY frequency ASC) AS F_score,
    NTILE(4) OVER (ORDER BY monetary ASC) AS M_score

FROM (
    SELECT
        CustomerID,

        DATEDIFF(
            (SELECT MAX(InvoiceDate)
             FROM ecommerce_sales
             WHERE UnitPrice > 0),
            MAX(InvoiceDate)
        ) AS recency_days,

        COUNT(DISTINCT InvoiceNo) AS frequency,

        ROUND(SUM(Revenue), 2) AS monetary

    FROM ecommerce_sales
    WHERE UnitPrice > 0
      AND CustomerID IS NOT NULL

    GROUP BY CustomerID
) AS rfm
) AS rfm_scores
) AS segmented_customers
GROUP BY customer_segment
ORDER BY customer_count DESC;

-- KPI 1: Total Revenue
SELECT
    ROUND(SUM(Revenue), 2) AS total_revenue
FROM ecommerce_sales
WHERE UnitPrice > 0;
-- KPI 2: Total Orders
SELECT
    COUNT(DISTINCT InvoiceNo) AS total_orders
FROM ecommerce_sales
WHERE UnitPrice > 0;
-- KPI 3: Total Customers
SELECT
    COUNT(DISTINCT CustomerID) AS total_customers
FROM ecommerce_sales
WHERE UnitPrice > 0
  AND CustomerID IS NOT NULL;
  -- KPI 4: Average Order Value
SELECT
    ROUND(
        SUM(Revenue) / COUNT(DISTINCT InvoiceNo),
        2
    ) AS average_order_value
FROM ecommerce_sales
WHERE UnitPrice > 0;
-- KPI 5: Repeat Purchase Rate
SELECT
    ROUND(
        100.0 * SUM(
            CASE
                WHEN customer_type = 'Repeat Customer' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS repeat_purchase_rate
FROM (
    SELECT
        CustomerID,
        CASE
            WHEN COUNT(DISTINCT InvoiceNo) > 1
                THEN 'Repeat Customer'
            ELSE 'One-Time Customer'
        END AS customer_type
    FROM ecommerce_sales
    WHERE UnitPrice > 0
      AND CustomerID IS NOT NULL
    GROUP BY CustomerID
) AS customers;
-- KPI 6: Customer Lifetime Value
SELECT
    ROUND(
        SUM(Revenue) / COUNT(DISTINCT CustomerID),
        2
    ) AS customer_lifetime_value
FROM ecommerce_sales
WHERE UnitPrice > 0
  AND CustomerID IS NOT NULL;
 -- KPI 7: Cancellation Rate
SELECT
    ROUND(
        100.0 * SUM(
            CASE
                WHEN InvoiceNo LIKE 'C%' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS cancellation_rate
FROM (
    SELECT DISTINCT InvoiceNo
    FROM ecommerce_sales
    WHERE InvoiceNo IS NOT NULL
) AS orders;
-- Check cancelled invoices
SELECT
    COUNT(*) AS cancelled_rows
FROM ecommerce_sales
WHERE InvoiceNo LIKE 'C%';
-- Check cancelled transactions using negative quantity
SELECT
    COUNT(*) AS cancelled_rows
FROM ecommerce_sales
WHERE Quantity < 0;

SELECT
    InvoiceNo,
    Quantity,
    UnitPrice,
    Revenue
FROM ecommerce_sales
WHERE Quantity < 0
LIMIT 10;
-- KPI 7: Average Items per Order
SELECT
    ROUND(
        SUM(Quantity) / COUNT(DISTINCT InvoiceNo),
        2
    ) AS average_items_per_order
FROM ecommerce_sales
WHERE UnitPrice > 0;
-- Monthly Revenue Trend
SELECT
    YEAR(InvoiceDate) AS year,
    MONTH(InvoiceDate) AS month,
    ROUND(SUM(Revenue), 2) AS monthly_revenue
FROM ecommerce_sales
WHERE UnitPrice > 0
GROUP BY
    YEAR(InvoiceDate),
    MONTH(InvoiceDate)
ORDER BY
    year,
    month;
-- Top 10 Products by Revenue
SELECT
    StockCode,
    Description,
    ROUND(SUM(Revenue), 2) AS total_revenue
FROM ecommerce_sales
WHERE UnitPrice > 0
GROUP BY
    StockCode,
    Description
ORDER BY
    total_revenue DESC
LIMIT 10;
-- Top 10 Customers by Revenue
SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    ROUND(SUM(Revenue), 2) AS total_revenue
FROM ecommerce_sales
WHERE UnitPrice > 0
  AND CustomerID IS NOT NULL
GROUP BY CustomerID
ORDER BY total_revenue DESC
LIMIT 10;
-- Revenue Contribution by Country
SELECT
    Country,
    ROUND(SUM(Revenue), 2) AS country_revenue,
    ROUND(
        100 * SUM(Revenue) /
        (SELECT SUM(Revenue)
         FROM ecommerce_sales
         WHERE UnitPrice > 0),
        2
    ) AS revenue_percentage
FROM ecommerce_sales
WHERE UnitPrice > 0
GROUP BY Country
ORDER BY country_revenue DESC;
-- Revenue by Customer Type

SELECT
    customer_type,
    COUNT(*) AS customer_count,
    ROUND(SUM(total_revenue), 2) AS total_revenue
FROM (
    SELECT
        CustomerID,
        CASE
            WHEN COUNT(DISTINCT InvoiceNo) > 1
                THEN 'Repeat Customer'
            ELSE 'One-Time Customer'
        END AS customer_type,
        SUM(Revenue) AS total_revenue
    FROM ecommerce_sales
    WHERE UnitPrice > 0
      AND CustomerID IS NOT NULL
    GROUP BY CustomerID
) AS customer_summary
GROUP BY customer_type
ORDER BY total_revenue DESC;
-- Revenue by Customer Type
SELECT
    customer_type,
    COUNT(*) AS customer_count,
    ROUND(SUM(total_revenue), 2) AS total_revenue
FROM (
    SELECT
        CustomerID,
        CASE
            WHEN COUNT(DISTINCT InvoiceNo) > 1
                THEN 'Repeat Customer'
            ELSE 'One-Time Customer'
        END AS customer_type,
        SUM(Revenue) AS total_revenue
    FROM ecommerce_sales
    WHERE UnitPrice > 0
      AND CustomerID IS NOT NULL
    GROUP BY CustomerID
) AS customer_summary
GROUP BY customer_type
ORDER BY total_revenue DESC;
-- Monthly Order Trend

SELECT
    YEAR(InvoiceDate) AS year,
    MONTH(InvoiceDate) AS month,
    COUNT(DISTINCT InvoiceNo) AS total_orders
FROM ecommerce_sales
WHERE UnitPrice > 0
GROUP BY
    YEAR(InvoiceDate),
    MONTH(InvoiceDate)
ORDER BY
    year,
    month;
-- Top 10 Products by Quantity Sold

SELECT
    StockCode,
    Description,
    SUM(Quantity) AS total_quantity_sold,
    ROUND(SUM(Revenue), 2) AS total_revenue
FROM ecommerce_sales
WHERE UnitPrice > 0
GROUP BY
    StockCode,
    Description
ORDER BY
    total_quantity_sold DESC
LIMIT 10;
-- Top 10 Customers by Number of Orders
SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    ROUND(SUM(Revenue), 2) AS total_revenue
FROM ecommerce_sales
WHERE UnitPrice > 0
  AND CustomerID IS NOT NULL
GROUP BY CustomerID
ORDER BY total_orders DESC
LIMIT 10;
-- Top 10 Customers by Revenue

SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    ROUND(SUM(Revenue), 2) AS total_revenue
FROM ecommerce_sales
WHERE UnitPrice > 0
  AND CustomerID IS NOT NULL
GROUP BY CustomerID
ORDER BY total_revenue DESC
LIMIT 10;
-- Revenue by Hour of Day
SELECT
    HOUR(InvoiceDate) AS hour_of_day,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    ROUND(SUM(Revenue), 2) AS total_revenue
FROM ecommerce_sales
WHERE UnitPrice > 0
GROUP BY HOUR(InvoiceDate)
ORDER BY hour_of_day;
-- Revenue and Orders by Day of Week
SELECT
    DAYNAME(InvoiceDate) AS day_of_week,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    ROUND(SUM(Revenue), 2) AS total_revenue
FROM ecommerce_sales
WHERE UnitPrice > 0
GROUP BY DAYNAME(InvoiceDate), DAYOFWEEK(InvoiceDate)
ORDER BY DAYOFWEEK(InvoiceDate);
-- Best Performing Month Overall
SELECT
    MONTHNAME(InvoiceDate) AS month_name,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    ROUND(SUM(Revenue), 2) AS total_revenue
FROM ecommerce_sales
WHERE UnitPrice > 0
GROUP BY MONTH(InvoiceDate), MONTHNAME(InvoiceDate)
ORDER BY total_revenue DESC; 
-- Average Order Value by Country

SELECT
    Country,
    ROUND(
        SUM(Revenue) / COUNT(DISTINCT InvoiceNo),
        2
    ) AS average_order_value
FROM ecommerce_sales
WHERE UnitPrice > 0
GROUP BY Country
ORDER BY average_order_value DESC;
-- Average Order Value by Customer Type

SELECT
    customer_type,
    ROUND(
        SUM(total_revenue) / SUM(total_orders),
        2
    ) AS average_order_value
FROM (
    SELECT
        CustomerID,
        COUNT(DISTINCT InvoiceNo) AS total_orders,
        SUM(Revenue) AS total_revenue,
        CASE
            WHEN COUNT(DISTINCT InvoiceNo) > 1
                THEN 'Repeat Customer'
            ELSE 'One-Time Customer'
        END AS customer_type
    FROM ecommerce_sales
    WHERE UnitPrice > 0
      AND CustomerID IS NOT NULL
    GROUP BY CustomerID
) AS customer_summary
GROUP BY customer_type
ORDER BY average_order_value DESC;
-- Revenue Contribution by Customer Type

SELECT
    customer_type,
    ROUND(
        100 * SUM(total_revenue) /
        (SELECT SUM(Revenue)
         FROM ecommerce_sales
         WHERE UnitPrice > 0),
        2
    ) AS revenue_percentage
FROM (
    SELECT
        CustomerID,
        SUM(Revenue) AS total_revenue,
        CASE
            WHEN COUNT(DISTINCT InvoiceNo) > 1
                THEN 'Repeat Customer'
            ELSE 'One-Time Customer'
        END AS customer_type
    FROM ecommerce_sales
    WHERE UnitPrice > 0
      AND CustomerID IS NOT NULL
    GROUP BY CustomerID
) AS customer_summary
GROUP BY customer_type
ORDER BY revenue_percentage DESC;
-- Monthly Revenue Growth
WITH monthly_revenue AS (
    SELECT
        YEAR(InvoiceDate) AS year,
        MONTH(InvoiceDate) AS month,
        ROUND(SUM(Revenue), 2) AS total_revenue
    FROM ecommerce_sales
    WHERE UnitPrice > 0
    GROUP BY YEAR(InvoiceDate), MONTH(InvoiceDate)
)

SELECT
    year,
    month,
    total_revenue,
    LAG(total_revenue) OVER (
        ORDER BY year, month
    ) AS previous_month_revenue,
    ROUND(
        100 * (
            total_revenue -
            LAG(total_revenue) OVER (ORDER BY year, month)
        ) /
        LAG(total_revenue) OVER (ORDER BY year, month),
        2
    ) AS growth_percentage
FROM monthly_revenue
ORDER BY year, month;
-- Top 10 Products by Average Selling Price
SELECT
    StockCode,
    Description,
    ROUND(AVG(UnitPrice), 2) AS average_selling_price,
    SUM(Quantity) AS total_quantity_sold
FROM ecommerce_sales
WHERE UnitPrice > 0
GROUP BY StockCode, Description
ORDER BY average_selling_price DESC
LIMIT 10;
-- Top 10 Products by Number of Orders

SELECT
    StockCode,
    Description,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    SUM(Quantity) AS total_quantity_sold,
    ROUND(SUM(Revenue), 2) AS total_revenue
FROM ecommerce_sales
WHERE UnitPrice > 0
GROUP BY StockCode, Description
ORDER BY total_orders DESC
LIMIT 10;
-- Average Revenue per Item by Product

SELECT
    StockCode,
    Description,
    ROUND(SUM(Revenue) / SUM(Quantity), 2) AS revenue_per_item,
    SUM(Quantity) AS total_quantity_sold,
    ROUND(SUM(Revenue), 2) AS total_revenue
FROM ecommerce_sales
WHERE UnitPrice > 0
  AND Quantity > 0
GROUP BY StockCode, Description
ORDER BY revenue_per_item DESC
LIMIT 10;
-- Monthly Average Order Value

SELECT
    YEAR(InvoiceDate) AS year,
    MONTH(InvoiceDate) AS month,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    ROUND(SUM(Revenue), 2) AS total_revenue,
    ROUND(
        SUM(Revenue) / COUNT(DISTINCT InvoiceNo),
        2
    ) AS average_order_value
FROM ecommerce_sales
WHERE UnitPrice > 0
GROUP BY
    YEAR(InvoiceDate),
    MONTH(InvoiceDate)
ORDER BY
    year,
    month;
    -- Customer Purchase Frequency

SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS total_orders
FROM ecommerce_sales
WHERE UnitPrice > 0
  AND CustomerID IS NOT NULL
GROUP BY CustomerID
ORDER BY total_orders DESC;
-- Customer Order Frequency Distribution

SELECT
    total_orders,
    COUNT(*) AS customer_count
FROM
(
    SELECT
        CustomerID,
        COUNT(DISTINCT InvoiceNo) AS total_orders
    FROM ecommerce_sales
    WHERE UnitPrice > 0
      AND CustomerID IS NOT NULL
    GROUP BY CustomerID
) AS customer_orders 
GROUP BY total_orders
ORDER BY total_orders; 
-- Average Order Value by Customer

SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    ROUND(SUM(Revenue), 2) AS total_revenue,
    ROUND(
        SUM(Revenue) / COUNT(DISTINCT InvoiceNo),
        2
    ) AS average_order_value
FROM ecommerce_sales
WHERE UnitPrice > 0
  AND CustomerID IS NOT NULL
GROUP BY CustomerID
ORDER BY average_order_value DESC
LIMIT 10;

-- High-Value Repeat Customers
SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    ROUND(SUM(Revenue), 2) AS total_revenue
FROM ecommerce_sales
WHERE UnitPrice > 0
  AND CustomerID IS NOT NULL
GROUP BY CustomerID
HAVING COUNT(DISTINCT InvoiceNo) >= 5
   AND SUM(Revenue) > 10000
ORDER BY total_revenue DESC;

-- Cancellation Impact on Revenue
SELECT
    ROUND(SUM(Revenue), 2) AS cancelled_revenue,
    COUNT(DISTINCT InvoiceNo) AS cancelled_orders
FROM ecommerce_sales
WHERE InvoiceNo LIKE 'C%'
  AND UnitPrice > 0;
  
  -- Revenue Impact of Returns
SELECT
    ROUND(SUM(Revenue), 2) AS return_value,
    COUNT(DISTINCT InvoiceNo) AS return_orders
FROM ecommerce_sales
WHERE Quantity < 0;

-- Top Customers by Lifetime Revenue
SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    ROUND(SUM(Revenue), 2) AS lifetime_revenue
FROM ecommerce_sales
WHERE UnitPrice > 0
  AND CustomerID IS NOT NULL
GROUP BY CustomerID
ORDER BY lifetime_revenue DESC
LIMIT 10; 
 
-- Customer Last Purchase Date
SELECT
    CustomerID,
    MAX(InvoiceDate) AS last_purchase_date,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    ROUND(SUM(Revenue), 2) AS lifetime_revenue
FROM ecommerce_sales
WHERE UnitPrice > 0
  AND CustomerID IS NOT NULL
GROUP BY CustomerID
ORDER BY last_purchase_date DESC
LIMIT 10;

-- Customer Spending Segmentation
SELECT
    CASE
        WHEN lifetime_revenue < 1000 THEN 'Low Spender'
        WHEN lifetime_revenue < 5000 THEN 'Medium Spender'
        ELSE 'High Spender'
    END AS spending_segment,
    COUNT(*) AS customer_count,
    ROUND(SUM(lifetime_revenue), 2) AS total_revenue
FROM (
    SELECT
        CustomerID,
        SUM(Revenue) AS lifetime_revenue
    FROM ecommerce_sales
    WHERE UnitPrice > 0
      AND CustomerID IS NOT NULL
    GROUP BY CustomerID
) AS customer_summary
GROUP BY spending_segment
ORDER BY total_revenue DESC;

-- Customer Purchase Lifespan
SELECT
    CustomerID,
    MIN(InvoiceDate) AS first_purchase_date,
    MAX(InvoiceDate) AS last_purchase_date,
    DATEDIFF(
        MAX(InvoiceDate),
        MIN(InvoiceDate)
    ) AS customer_lifespan_days
FROM ecommerce_sales
WHERE UnitPrice > 0
  AND CustomerID IS NOT NULL
GROUP BY CustomerID
ORDER BY customer_lifespan_days DESC 
LIMIT 10;
-- Long-Term High-Value Customers

SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    ROUND(SUM(Revenue), 2) AS lifetime_revenue,
    DATEDIFF(MAX(InvoiceDate), MIN(InvoiceDate)) AS lifespan_days
FROM ecommerce_sales
WHERE UnitPrice > 0
  AND CustomerID IS NOT NULL
GROUP BY CustomerID
HAVING COUNT(DISTINCT InvoiceNo) >= 20
   AND SUM(Revenue) >= 10000
ORDER BY lifetime_revenue DESC
LIMIT 10;   


 