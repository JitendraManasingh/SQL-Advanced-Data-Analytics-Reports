/**************************************************************************************************
    Product Report
    Author : Jitendra Kumar Manasingh
**************************************************************************************************/

/**************************************************************************************************
    1. Product Report View
**************************************************************************************************/

CREATE VIEW gold.report_products AS
WITH base_query AS (
    SELECT
        f.order_number,
        f.order_date,
        f.product_key,
        f.sales_amount,
        f.quantity,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        DATEDIFF(year, c.birthdate, GETDATE()) AS age
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_products AS p
        ON f.product_key = p.product_key
    LEFT JOIN gold.dim_customers AS c
        ON f.customer_key = c.customer_key
    WHERE f.order_date IS NOT NULL
),
product_aggregation AS (
    SELECT
        product_key,
        product_name,
        category,
        subcategory,
        cost,
        DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan,
        MAX(order_date) AS last_order_date,
        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT customer_name) AS total_customers,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 2) AS avg_selling_price
    FROM base_query
    GROUP BY 
        product_key,
        product_name,
        category,
        subcategory,
        cost
)
SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    last_order_date,
    DATEDIFF(month, last_order_date, GETDATE()) AS recency,
    CASE 
        WHEN total_sales > 50000 THEN 'High-Performer'
        WHEN total_sales > 10000 THEN 'Mid-Range'
        ELSE 'Lower-Performer'
    END AS product_segment,
    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    avg_selling_price,
    -- Average Order Revenue (AOR)
    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_revenue,
    -- Average Monthly Revenue (AMR)
    CASE 
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_revenue
FROM product_aggregation;



/**************************************************************************************************
    2. Preview
**************************************************************************************************/
SELECT * FROM gold.report_products;
