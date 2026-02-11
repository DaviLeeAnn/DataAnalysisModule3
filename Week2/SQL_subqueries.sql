USE coffeeshop_db;

-- =========================================================
-- SUBQUERIES & NESTED LOGIC PRACTICE
-- =========================================================

-- Q1) Scalar subquery (AVG benchmark):
--     List products priced above the overall average product price.
--     Return product_id, name, price.
SELECT product_id, name, price
FROM products
WHERE price > (SELECT AVG(price) FROM products);

-- Q2) Scalar subquery (MAX within category):
--     Find the most expensive product(s) in the 'Beans' category.
--     (Return all ties if more than one product shares the max price.)
--     Return product_id, name, price.
SELECT product_id, name, price
FROM products
WHERE category_id = (SELECT category_id FROM categories WHERE name = 'beans')
AND price =
(SELECT MAX(price)
FROM products
WHERE category_id = (SELECT category_id FROM categories WHERE name = 'beans'));

-- Q3) List subquery (IN with nested lookup):
--     List customers who have purchased at least one product in the 'Merch' category.
--     Return customer_id, first_name, last_name.
--     Hint: Use a subquery to find the category_id for 'Merch', then a subquery to find product_ids.
SELECT DISTINCT customer_id, first_name, last_name
FROM customers
WHERE customer_id IN (
	SELECT customer_id
	FROM orders
	WHERE order_id IN (
		SELECT order_id
		FROM order_items
		WHERE product_id IN (
			SELECT product_id 
            FROM products 
            WHERE category_id = (
				SELECT category_id 
                FROM categories 
                WHERE name = 'Merch'))));

-- Q4) List subquery (NOT IN / anti-join logic):
--     List products that have never been ordered (their product_id never appears in order_items).
--     Return product_id, name, price.
SELECT product_id, name, price
FROM products
WHERE product_id NOT IN (SELECT product_id FROM order_items);

-- Q5) Table subquery (derived table + compare to overall average):
--     Build a derived table that computes total_units_sold per product
--     (SUM(order_items.quantity) grouped by product_id).
--     Then return only products whose total_units_sold is greater than the
--     average total_units_sold across all products.
--     Return product_id, product_name, total_units_sold.
SELECT pt.product_id, p.name AS product_name, pt.total_units_sold
FROM (SELECT product_id, SUM(quantity) AS total_units_sold
		FROM order_items
		GROUP BY product_id) AS pt
JOIN products p ON pt.product_id = p.product_id
WHERE pt.total_units_sold > 
	(SELECT AVG(total_units_sold) 
		FROM (SELECT product_id, SUM(quantity) AS total_units_sold
		FROM order_items
		GROUP BY product_id) AS avg_calc);