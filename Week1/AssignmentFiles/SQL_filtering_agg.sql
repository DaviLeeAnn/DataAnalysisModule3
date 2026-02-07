-- ==================================
-- FILTERS & AGGREGATION
-- ==================================

USE coffeeshop_db;


-- Q1) Compute total items per order.
--     Return (order_id, total_items) from order_items.
select order_id, sum(quantity) as total_items from order_items
group by order_id;

-- Q2) Compute total items per order for PAID orders only.
--     Return (order_id, total_items). Hint: order_id IN (SELECT ... FROM orders WHERE status='paid').
select orders.order_id, sum(order_items.quantity) as total_items
from order_items
where order_id in(select order_id from orders where status = 'paid')
group by order_id;

-- Q3) How many orders were placed per day (all statuses)?
--     Return (order_date, orders_count) from orders.
select order_datetime as order_date,
count(*) as orders_count from orders
group by order_datetime
order by order_date;

-- Q4) What is the average number of items per PAID order?
--     Use a subquery or CTE over order_items filtered by order_id IN (...).
select quantity from(
select order_id, sum(quantity) as items
from order_items where order_id in(select order_id from orders where status = 'paid')
group by order_id)
as paid_orders;

-- Q5) Which products (by product_id) have sold the most units overall across all stores?
--     Return (product_id, total_units), sorted desc.
select product_id, sum(quantity) as total_units
from order_items
group by product_id
order by total_units desc;

-- Q6) Among PAID orders only, which product_ids have the most units sold?
--     Return (product_id, total_units_paid), sorted desc.
--     Hint: order_id IN (SELECT order_id FROM orders WHERE status='paid').
select product_id, sum(quantity) as total_units_paid_only
from order_items
where order_id in(
select order_id from orders where status = 'paid')
group by product_id
order by total_units_paid_only desc;

-- Q7) For each store, how many UNIQUE customers have placed a PAID order?
--     Return (store_id, unique_customers) using only the orders table.
select store_id, count(distinct customer_id) as unique_customers from orders
where status = 'paid'
group by store_id
order by store_id;

-- Q8) Which day of week has the highest number of PAID orders?
--     Return (day_name, orders_count). Hint: DAYNAME(order_datetime). Return ties if any.
select dayname(order_datetime) as day_name, count(*) as orders_count from orders where status = 'paid'
group by dayname(order_datetime)
having count(*) = (
select count(*) as orders_count from orders where status = 'paid'
group by dayname(order_datetime)
order by orders_count desc
limit 1);

-- Q9) Show the calendar days whose total orders (any status) exceed 3.
--     Use HAVING. Return (order_date, orders_count).
select date(order_datetime) as order_date, count(*) as orders_count from orders
group by date(order_datetime)
having count(*) > 3
order by order_date;

-- Q10) Per store, list payment_method and the number of PAID orders.
--      Return (store_id, payment_method, paid_orders_count).
select store_id, payment_method, count(*) as paid_orders_count from orders
where status = 'paid'
group by store_id, payment_method
order by store_id, payment_method;

-- Q11) Among PAID orders, what percent used 'app' as the payment_method?
--      Return a single row with pct_app_paid_orders (0–100).
select
(select count(*) from orders where status = 'paid' and payment_method = 'app') * 100
/
(select count(*) from orders where status = 'paid')
as pct_app_paid_orders;

-- Q12) Busiest hour: for PAID orders, show (hour_of_day, orders_count) sorted desc.
select hour(order_datetime) as hour_of_day, count(*) as orders_count from orders
where status = 'paid'
group by hour(order_datetime)
order by orders_count desc;

-- ================
