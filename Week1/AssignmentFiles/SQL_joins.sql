USE coffeeshop_db;

-- =========================================================
-- JOINS & RELATIONSHIPS PRACTICE
-- =========================================================

-- Q1) Join products to categories: list product_name, category_name, price.
select products.name as product_name,
categories.name as category_name,
products.price
from products
inner join categories on products.category_id = categories.category_id;

-- Q2) For each order item, show: order_id, order_datetime, store_name,
--     product_name, quantity, line_total (= quantity * products.price).
--     Sort by order_datetime, then order_id.
select order_items.order_id,
orders.order_datetime,
stores.name as store_name,
products.name as product_name,
order_items.quantity,
(order_items.quantity * products.price) as line_total
from order_items
inner join orders on order_items.order_id = orders.order_id
inner join stores on orders.store_id = stores.store_id
inner join products on order_items.product_id = products.product_id
order by orders.order_datetime, order_items.order_id;

-- Q3) Customer order history (PAID only):
--     For each order, show customer_name, store_name, order_datetime,
--     order_total (= SUM(quantity * products.price) per order).
select concat(customers.first_name, ' ', customers.last_name) as customer_name,
stores.name as store_name,
orders.order_datetime,
sum(order_items.quantity * products.price) as order_total
from orders
inner join customers on orders.customer_id = customers.customer_id
inner join stores on orders.store_id = stores.store_id
inner join order_items on orders.order_id = order_items.order_id
inner join products on order_items.product_id = products.product_id
where orders.status = 'paid'
group by orders.order_id
order by orders.order_datetime;

-- Q4) Left join to find customers who have never placed an order.
--     Return first_name, last_name, city, state.
select customers.first_name,
customers.last_name,
customers.city,
customers.state
from customers
left join orders on customers.customer_id = orders.customer_id
where orders.order_id is null;

-- Q5) For each store, list the top-selling product by units (PAID only).
--     Return store_name, product_name, total_units.
--     Hint: Use a window function (ROW_NUMBER PARTITION BY store) or a correlated subquery.
select store_name, product_name, total_units
from 
(select stores.name as store_name,
products.name as product_name,
sum(order_items.quantity) as total_units,
row_number() over (partition by stores.store_id order by sum(order_items.quantity) desc) as rank_num
from orders
inner join stores on orders.store_id = stores.store_id
inner join order_items on orders.order_id = order_items.order_id
inner join products on order_items.product_id = products.product_id
where orders.status = 'paid'
group by stores.store_id, stores.name, products.product_id, products.name)
as ranked_products
where rank_num = 1;

-- Q6) Inventory check: show rows where on_hand < 12 in any store.
--     Return store_name, product_name, on_hand.


-- Q7) Manager roster: list each store's manager_name and hire_date.
--     (Assume title = 'Manager').


-- Q8) Using a subquery/CTE: list products whose total PAID revenue is above
--     the average PAID product revenue. Return product_name, total_revenue.


-- Q9) Churn-ish check: list customers with their last PAID order date.
--     If they have no PAID orders, show NULL.
--     Hint: Put the status filter in the LEFT JOIN's ON clause to preserve non-buyer rows.


-- Q10) Product mix report (PAID only):
--     For each store and category, show total units and total revenue (= SUM(quantity * products.price)).

