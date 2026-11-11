
-- ============================================================================
-- PROJECT: SQL Retail Sales Analytics (Olist E-Commerce Dataset)
-- SCRIPT: 06_business_analysis.sql (SINGLE-TABLE T-SQL EDITION)
-- DESCRIPTION: Final business analysis optimized for dbo.practice_by_Olist
-- AUTHOR: Junior Data Analyst
-- ============================================================================

-- Q1: How many orders are recorded?
SELECT COUNT(DISTINCT order_id) AS total_orders_recorded
FROM dbo.practice_by_Olist;

-- Q2: How many distinct customers placed orders?
SELECT COUNT(DISTINCT customer_unique_id) AS total_distinct_customers
FROM dbo.practice_by_Olist;

-- Q3: What order statuses exist and how frequent are they?
SELECT 
    order_status,
    COUNT(DISTINCT order_id) AS status_count,
    ROUND((COUNT(DISTINCT order_id) * 100.0 / (SELECT COUNT(DISTINCT order_id) FROM dbo.practice_by_Olist)), 2) AS status_percentage
FROM dbo.practice_by_Olist
GROUP BY order_status
ORDER BY status_count DESC;

-- Q4: What is the average item selling price?
SELECT ROUND(AVG(CAST(price AS DECIMAL(10,2))), 2) AS average_item_selling_price
FROM dbo.practice_by_Olist;

-- Q5: Which five states contain the most customers?
SELECT TOP 5 
    customer_state,
    COUNT(DISTINCT customer_unique_id) AS customer_count
FROM dbo.practice_by_Olist
GROUP BY customer_state
ORDER BY customer_count DESC;

-- Q6: What is the total item sales value for delivered orders?
SELECT ROUND(SUM(CAST(price AS DECIMAL(18,2))), 2) AS total_delivered_item_sales
FROM dbo.practice_by_Olist
WHERE order_status = 'delivered';

-- Q7: Which product categories generate the most item sales value?
SELECT 
    ISNULL(product_category_name, 'unknown/unlabeled') AS product_category,
    ROUND(SUM(CAST(price AS DECIMAL(18,2))), 2) AS total_item_sales_value
FROM dbo.practice_by_Olist
WHERE order_status <> 'canceled'
GROUP BY product_category_name
ORDER BY total_item_sales_value DESC;

-- Q8: What are the ten highest-selling products by item sales value?
SELECT TOP 10 
    product_id,
    MAX(product_category_name) AS product_category,
    COUNT(order_item_id) AS units_sold,
    ROUND(SUM(CAST(price AS DECIMAL(18,2))), 2) AS total_item_sales_value
FROM dbo.practice_by_Olist
WHERE order_status <> 'canceled'
GROUP BY product_id
ORDER BY total_item_sales_value DESC;

-- Q9: How does item sales value change month by month?
SELECT 
    FORMAT(order_purchase_timestamp, 'yyyy-MM') AS purchase_month,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(CAST(price AS DECIMAL(18,2))), 2) AS total_item_sales_value
FROM dbo.practice_by_Olist
WHERE order_status <> 'canceled'
GROUP BY FORMAT(order_purchase_timestamp, 'yyyy-MM')
ORDER BY purchase_month ASC;

-- Q10: What percentage of orders were canceled?
WITH unique_orders AS (
    SELECT DISTINCT order_id, order_status FROM dbo.practice_by_Olist
)
SELECT 
    COUNT(CASE WHEN order_status = 'canceled' THEN 1 END) AS canceled_orders_count,
    COUNT(order_id) AS total_orders_count,
    ROUND((COUNT(CASE WHEN order_status = 'canceled' THEN 1 END) * 100.0 / COUNT(order_id)), 2) AS cancellation_percentage
FROM unique_orders;

-- Q11: Which customers have placed multiple orders?
SELECT 
    customer_unique_id,
    COUNT(DISTINCT order_id) AS total_orders_placed
FROM dbo.practice_by_Olist
GROUP BY customer_unique_id
HAVING COUNT(DISTINCT order_id) > 1
ORDER BY total_orders_placed DESC;

-- Q12: Who are the highest-spending customers?
SELECT TOP 10 
    customer_unique_id,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(CAST(price AS DECIMAL(18,2))), 2) AS total_item_spend
FROM dbo.practice_by_Olist
WHERE order_status <> 'canceled'
GROUP BY customer_unique_id
ORDER BY total_item_spend DESC;

-- Q13: How does delivery time vary by customer state?
SELECT 
    customer_state,
    COUNT(DISTINCT order_id) AS orders_delivered,
    ROUND(AVG(CAST(DATEDIFF(day, order_purchase_timestamp, order_delivered_customer_date) AS DECIMAL(10,1))), 1) AS avg_delivery_days
FROM dbo.practice_by_Olist
WHERE order_status = 'delivered' 
  AND order_delivered_customer_date IS NOT NULL
GROUP BY customer_state
ORDER BY avg_delivery_days DESC;

-- Q15: How can customers be segmented using RFM?
WITH customer_order_totals AS (
    SELECT 
        customer_unique_id,
        order_id,
        MAX(order_purchase_timestamp) AS order_purchase_timestamp,
        SUM(CAST(price AS DECIMAL(18,2))) AS total_order_item_price
    FROM dbo.practice_by_Olist
    WHERE order_status <> 'canceled'
    GROUP BY customer_unique_id, order_id
),
rfm_base AS (
    SELECT 
        customer_unique_id,
        DATEDIFF(day, MAX(order_purchase_timestamp), (SELECT MAX(order_purchase_timestamp) FROM dbo.practice_by_Olist)) AS recency_days,
        COUNT(DISTINCT order_id) AS frequency,
        SUM(total_order_item_price) AS monetary_value
    FROM customer_order_totals
    GROUP BY customer_unique_id
),
rfm_scores AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY recency_days ASC) AS r_score,
        CASE 
            WHEN frequency = 1 THEN 1
            WHEN frequency = 2 THEN 3
            ELSE 5
        END AS f_score,
        NTILE(5) OVER (ORDER BY monetary_value DESC) AS m_score
    FROM rfm_base
)
SELECT 
    customer_unique_id,
    recency_days,
    frequency,
    ROUND(CAST(monetary_value AS DECIMAL(18,2)), 2) AS total_monetary_spend,
    r_score, f_score, m_score,
    CASE 
        WHEN f_score >= 3 AND m_score >= 4 THEN 'VIP/Champions'
        WHEN r_score <= 2 AND f_score = 1 THEN 'New Acquisitions'
        WHEN r_score >= 4 AND f_score >= 3 THEN 'At Risk / Churning'
        WHEN r_score >= 4 AND f_score = 1 THEN 'Dormant One-Timers'
        ELSE 'General Value Buyers'
    END AS customer_rfm_segment
FROM rfm_scores
ORDER BY total_monetary_spend DESC;
│   ├── 01_basic_queries.sql        # Foundational data preparation queries
│   ├── 02_aggregations.sql         # Aggregation metrics
│   └── 06_business_analysis.sql    # Final script answering the 15 business questions
└── docs/
    └── business_insights.md        # Comprehensive executive insights markdown report
```

---

## ⚡ Prerequisites & Environment Setup
To replicate this analytical project on a local machine, follow these configurations:

1. **Database Platform:** Microsoft SQL Server (2019 or newer)
2. **Management Interface:** SQL Server Management Studio (SSMS) or DBeaver
3. **Data Source Access:** Download the raw files from the official source link rather than checking heavy CSV data into source control: [Kaggle Olist E-Commerce Dataset](https://kaggle.com).

---

## 🏁 Reproducible Execution Sequence

Follow these operational steps to build the complete workspace environment:

### Step 1: Initialize Database Context
Open your management console (SSMS), establish a local server connection, and run this configuration layout to build a clean target database container:
```sql
CREATE DATABASE olist_practice;
GO
```

### Step 2: Ingest the Consolidated Flat Table Data
Because the source files were compiled into a wide single table schema layout for unified querying, import your primary dataset directly into a table named:
`dbo.practice_by_Olist`

### Step 3: Run the Business Verification Queries
Open and execute the final master script located in your file path:  
📂 `sql/06_business_analysis.sql`

---

## 📊 Summary of Core Project Metrics

*   **Total Orders Tracked (Q1):** 95,128 unique checkout events verified via distinct filters.
*   **Total Active Buyers (Q2):** 92,081 human customers tracked via unique identities.
*   **Pipeline Health Index (Q3):** 99.99% Delivered status against a 0.01% Canceled rate.
*   **Average Marketplace Basket Value (Q4):** 120.18 per transaction line.
*   **Top 5 Regional Density Hubs (Q5):** São Paulo (SP), Rio de Janeiro (RJ), Minas Gerais (MG), Rio Grande do Sul (RS), and Paraná (PR).
*   **Gross Commercial Realized Revenue (Q6):** 13,627,024.05 net item value.
