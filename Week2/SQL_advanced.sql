USE coffeeshop_db;

-- =========================================================
-- ADVANCED SQL ASSIGNMENT
-- Subqueries, CTEs, Window Functions, Views
-- =========================================================
-- Notes:
-- - Unless a question says otherwise, use orders with status = 'paid'.
-- - Write ONE query per prompt.
-- - Keep results readable (use clear aliases, ORDER BY where it helps).

-- =========================================================
-- Q1) Correlated subquery: Above-average order totals (PAID only)
-- =========================================================
-- For each PAID order, compute order_total (= SUM(quantity * products.price)).
-- Return: order_id, customer_name, store_name, order_datetime, order_total.
-- Filter to orders where order_total is greater than the average PAID order_total
-- for THAT SAME store (correlated subquery).
-- Sort by store_name, then order_total DESC.
SELECT
	o.order_id,
	CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    s.name AS store_name,
    o.order_datetime,
    SUM(oi.quantity * p.price) AS order_total
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN stores s ON s.store_id = o.store_id
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.status = 'paid'
GROUP BY o.order_id, customer_name, store_name, o.order_datetime
HAVING order_total > 
	(SELECT AVG(SUM(oi2.quantity * p2.price))
	FROM orders o2
	JOIN order_items oi2 on oi2.order_id = o2.order_id
	join products p2 on p2.product_id = oi2.product_id
	WHERE o2.status = 'paid'
		AND o2.store_id = o.store_id
	GROUP BY o2.order_id)
ORDER BY store_name, order_total DESC;

-- =========================================================
-- Q2) CTE: Daily revenue and 3-day rolling average (PAID only)
-- =========================================================
-- Using a CTE, compute daily revenue per store:
--   revenue_day = SUM(quantity * products.price) grouped by store_id and DATE(order_datetime).
-- Then, for each store and date, return:
--   store_name, order_date, revenue_day,
--   rolling_3day_avg = average of revenue_day over the current day and the prior 2 days.
-- Use a window function for the rolling average.
-- Sort by store_name, order_date.
WITH daily_revenue AS 
    (SELECT
        o.store_id,
        DATE(o.order_datetime) AS order_date,
        SUM(oi.quantity * p.price) AS revenue_day
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN products p ON p.product_id = oi.product_id
    WHERE o.status = 'paid'
    GROUP BY o.store_id, DATE(o.order_datetime))
SELECT
    s.name AS store_name,
    dr.order_date,
    dr.revenue_day,
    AVG(dr.revenue_day) 
OVER
	(PARTITION BY dr.store_id
	ORDER BY dr.order_date
	ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
AS rolling_3day_avg
FROM daily_revenue dr
JOIN stores s ON s.store_id = dr.store_id
ORDER BY store_name, order_date;

-- =========================================================
-- Q3) Window function: Rank customers by lifetime spend (PAID only)
-- =========================================================
-- Compute each customer's total spend across ALL stores (PAID only).
-- Return: customer_id, customer_name, total_spend,
--         spend_rank (DENSE_RANK by total_spend DESC).
-- Also include percent_of_total = customer's total_spend / total spend of all customers.
-- Sort by total_spend DESC.
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    SUM(oi.quantity * p.price) AS total_spend,
    DENSE_RANK() OVER 
    (ORDER BY SUM(oi.quantity * p.price) DESC) AS spend_rank,
	round (SUM(oi.quantity * p.price) / SUM(SUM(oi.quantity * p.price)) OVER () * 100, 2) AS percent_of_total
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.status = 'paid'
GROUP BY c.customer_id, customer_name
ORDER BY total_spend DESC;

-- =========================================================
-- Q4) CTE + window: Top product per store by revenue (PAID only)
-- =========================================================
-- For each store, find the top-selling product by REVENUE (not units).
-- Revenue per product per store = SUM(quantity * products.price).
-- Return: store_name, product_name, category_name, product_revenue.
-- Use a CTE to compute product_revenue, then a window function (ROW_NUMBER)
-- partitioned by store to select the top 1.
-- Sort by store_name.
WITH product_revenue AS (
    SELECT
        o.store_id,
        p.product_id,
        p.name AS product_name,
        cat.name AS category_name,
        SUM(oi.quantity * p.price) AS product_revenue
	FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN products p ON p.product_id = oi.product_id
    JOIN categories cat ON cat.category_id = p.category_id
    WHERE o.status = 'paid'
    GROUP BY o.store_id, p.product_id, p.name, cat.name),
RANKED AS
	(SELECT
        s.name AS store_name,
        pr.product_name,
        pr.category_name,
        pr.product_revenue,
        ROW_NUMBER() OVER
			(PARTITION BY pr.store_id
            ORDER BY pr.product_revenue DESC)
	AS rn
	FROM product_revenue pr
    JOIN stores s ON s.store_id = pr.store_id)
SELECT
    store_name,
    product_name,
    category_name,
    product_revenue
FROM ranked
WHERE rn = 1
ORDER BY store_name;

-- =========================================================
-- Q5) Subquery: Customers who have ordered from ALL stores (PAID only)
-- =========================================================
-- Return customers who have at least one PAID order in every store in the stores table.
-- Return: customer_id, customer_name.
-- Hint: Compare count(distinct store_id) per customer to (select count(*) from stores).
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE o.status = 'paid'
GROUP BY c.customer_id, customer_name
HAVING COUNT(DISTINCT o.store_id) = (SELECT COUNT(*) FROM stores)
ORDER BY customer_name;

-- =========================================================
-- Q6) Window function: Time between orders per customer (PAID only)
-- =========================================================
-- For each customer, list their PAID orders in chronological order and compute:
--   prev_order_datetime (LAG),
--   minutes_since_prev (difference in minutes between current and previous order).
-- Return: customer_name, order_id, order_datetime, prev_order_datetime, minutes_since_prev.
-- Only show rows where prev_order_datetime is NOT NULL.
-- Sort by customer_name, order_datetime.
WITH order_lags AS
	(SELECT
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        o.order_id,
        o.order_datetime,
        LAG(o.order_datetime)
	OVER 
		(PARTITION BY o.customer_id
		ORDER BY o.order_datetime)
	AS prev_order_datetime
    FROM orders o
    JOIN customers c ON c.customer_id = o.customer_id
    WHERE o.status = 'paid')
SELECT
    customer_name,
    order_id,
    order_datetime,
    prev_order_datetime,
    TIMESTAMPDIFF(MINUTE, prev_order_datetime, order_datetime) AS minutes_since_prev
FROM order_lags
WHERE prev_order_datetime IS NOT NULL
ORDER BY customer_name, order_datetime;

-- =========================================================
-- Q7) View: Create a reusable order line view for PAID orders
-- =========================================================
-- Create a view named v_paid_order_lines that returns one row per PAID order item:
--   order_id, order_datetime, store_id, store_name,
--   customer_id, customer_name,
--   product_id, product_name, category_name,
--   quantity, unit_price (= products.price),
--   line_total (= quantity * products.price)
--
-- After creating the view, write a SELECT that uses the view to return:
--   store_name, category_name, revenue
-- where revenue is SUM(line_total),
-- sorted by revenue DESC.
CREATE VIEW v_paid_order_lines AS
SELECT
    o.order_id,
    o.order_datetime,
    o.store_id,
    s.name AS store_name,
    o.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    p.product_id,
    p.name AS product_name,
    cat.name AS category_name,
    oi.quantity,
    p.price AS unit_price,
    oi.quantity * p.price AS line_total
FROM orders o
JOIN stores s ON s.store_id = o.store_id
JOIN customers c ON c.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
JOIN categories cat ON cat.category_id = p.category_id
WHERE o.status = 'paid';
---
SELECT
    store_name,
    category_name,
    SUM(line_total) AS revenue
FROM v_paid_order_lines
GROUP BY store_name, category_name
ORDER BY revenue DESC;

-- =========================================================
-- Q8) View + window: Store revenue share by payment method (PAID only)
-- =========================================================
-- Create a view named v_paid_store_payments with:
--   store_id, store_name, payment_method, revenue
-- where revenue is total PAID revenue for that store/payment_method.
--
-- Then query the view to return:
--   store_name, payment_method, revenue,
--   store_total_revenue (window SUM over store),
--   pct_of_store_revenue (= revenue / store_total_revenue)
-- Sort by store_name, revenue DESC.
CREATE VIEW v_paid_store_payments AS
SELECT
    o.store_id,
    s.name AS store_name,
    o.payment_method,
    SUM(oi.quantity * p.price) AS revenue
FROM orders o
JOIN stores s ON s.store_id = o.store_id
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.status = 'paid'
GROUP BY o.store_id, s.name, o.payment_method;
---
SELECT
    store_name,
    payment_method,
    revenue,
	SUM(revenue) OVER (PARTITION BY store_id) AS store_total_revenue,
	ROUND(revenue / SUM(revenue) OVER (PARTITION BY store_id) * 100, 2) AS pct_of_store_revenue
FROM v_paid_store_payments
ORDER BY store_name, revenue DESC;

-- =========================================================
-- Q9) CTE: Inventory risk report (low stock relative to sales)
-- =========================================================
-- Identify items where on_hand is low compared to recent demand:
-- Using a CTE, compute total_units_sold per store/product for PAID orders.
-- Then join inventory to that result and return rows where:
--   on_hand < total_units_sold
-- Return: store_name, product_name, on_hand, total_units_sold, units_gap (= total_units_sold - on_hand)
-- Sort by units_gap DESC.
WITH units_sold AS
	(SELECT
        o.store_id,
        oi.product_id,
        SUM(oi.quantity) AS total_units_sold
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'paid'
    GROUP BY o.store_id, oi.product_id)
SELECT
    s.name AS store_name,
    p.name AS product_name,
    i.on_hand,
    us.total_units_sold,
    us.total_units_sold - i.on_hand AS units_gap
FROM inventory i
JOIN units_sold us ON us.store_id = i.store_id
	AND us.product_id = i.product_id
JOIN stores s ON s.store_id = i.store_id
JOIN products p ON p.product_id = i.product_id
WHERE i.on_hand < us.total_units_sold
ORDER BY units_gap DESC;