/**************************************************************************************************
    Customer Segmentation & Customer Report
    Author : Jitendra Kumar Manasingh
    Purpose: 
        - Segment customers into groups (VIP, Regular, New)
        - Create a consolidated customer report with KPIs and metrics
**************************************************************************************************/

/**************************************************************************************************
    1. Customer Segmentation
    Logic:
        - VIP     : At least 12 months of history AND spending more than €5,000
        - Regular : At least 12 months of history AND spending €5,000 or less
        - New     : Lifespan less than 12 months
**************************************************************************************************/

WITH CTE_customer_spending AS (
    SELECT
        c.customer_key,
        SUM(f.sales_amount) AS total_spending,
        MIN(f.order_date) AS first_order,
        MAX(f.order_date) AS last_order,
        DATEDIFF(month, MIN(f.order_date), MAX(f.order_date)) AS lifespan
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_customers AS c
        ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
)
SELECT
    customer_segments,
    COUNT(customer_key) AS total_customers
FROM (
    SELECT
        customer_key,
        CASE 
            WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_segments
    FROM CTE_customer_spending
) t
GROUP BY customer_segments
ORDER BY total_customers DESC;



/**************************************************************************************************
    2. Customer Report
    Purpose:
        - Consolidate key customer metrics and behaviors
    Highlights:
        1. Gather essential fields such as name, age, and transaction details
        2. Segment customers into categories (VIP, Regular, New) and age groups
        3. Aggregate customer-level metrics:
            - Total orders
            - Total sales
            - Total quantity purchased
            - Total products purchased
            - Lifespan (in months)
        4. Calculate valuable KPIs:
            - Recency (months since last order)
            - Average Order Value (AOV)
            - Average Monthly Spend
**************************************************************************************************/

CREATE VIEW gold.report_customers AS
WITH base_query AS (
    -- Base Query: Retrieve core columns from fact and dimension tables
    SELECT
        f.order_number,
        f.product_key,
        f.order_date,
        f.sales_amount,
        f.quantity,
        c.customer_key,
        c.customer_number,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        DATEDIFF(year, c.birthdate, GETDATE()) AS age
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_customers AS c
        ON f.customer_key = c.customer_key
    WHERE order_date IS NOT NULL
),
customer_aggregation AS (
    -- Customer Aggregation: Summarizes key metrics at the customer level
    SELECT
        customer_key,
        customer_number,
        customer_name,
        age,
        COUNT(DISTINCT order_number) AS total_order,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT product_key) AS total_products,
        MAX(order_date) AS last_order_date,
        DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
    FROM base_query
    GROUP BY 
        customer_key,
        customer_number,
        customer_name,
        age
)
SELECT
    customer_key,
    customer_number,
    customer_name,
    age,
    CASE 
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50 and above'
    END AS age_group,
    CASE 
        WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segments,
    last_order_date,
    DATEDIFF(month, last_order_date, GETDATE()) AS recency,
    total_order,
    total_sales,
    total_quantity,
    total_products,
    lifespan,
    -- Compute Average Order Value (AOV)
    CASE 
        WHEN total_sales = 0 THEN 0
        ELSE total_sales / total_order
    END AS avg_order_value,
    -- Compute Average Monthly Spend
    CASE 
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_spend
FROM customer_aggregation;



/**************************************************************************************************
    3. Preview the Customer Report
**************************************************************************************************/

SELECT * 
FROM gold.report_customers;
