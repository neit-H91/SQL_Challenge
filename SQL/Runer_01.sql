SET search_path TO pizza_runner;

-- cleaning my tables
update pizza_runner.customer_orders
set extras=''
where extras = 'null' or extras is null;

update pizza_runner.customer_orders
set exclusions=''
where exclusions = 'null' or exclusions is null;

update runner_orders
set cancellation = ''
where cancellation = 'null' or cancellation is null;

-- How many pizzas were ordered?
select count(*)
from pizza_runner.customer_orders;

-- How many unique customer orders were made?
select count(distinct order_id)
from pizza_runner.customer_orders;

-- How many successful orders were delivered by each runner?
select count(*), runner_id
from runner_orders
where pickup_time <> 'null'
group by runner_id;

-- How many of each type of pizza was delivered?
select count(pizza_id)
from runner_orders r
join customer_orders c
on r.order_id = c.order_id
where cancellation = ''
group by pizza_id;

-- How many Vegetarian and Meatlovers were ordered by each customer?
select count(pizza_name),customer_id, pizza_name
from customer_orders o
join pizza_names p
on o.pizza_id = p.pizza_id
group by customer_id, pizza_name;

-- What was the maximum number of pizzas delivered in a single order?
select count(pizza_id), order_id
from customer_orders
group by order_id
order by count(pizza_id) desc
limit 1;

-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
select 
sum(case when exclusions = '' and extras = '' then 1 end) as total_no_change,
sum(case when exclusions <> '' or extras <> '' then 1 end) as total_one_change,
customer_id
from customer_orders c
join runner_orders r
on c.order_id = r.order_id
where cancellation = ''
group by customer_id;

-- How many pizzas were delivered that had both exclusions and extras?
select sum(case when exclusions <> '' and extras <> '' then 1 end) as total
from customer_orders c
join runner_orders r
on c.order_id = r.order_id
where cancellation = '';

-- What was the total volume of pizzas ordered for each hour of the day?
select count(*) as total, DATE_TRUNC('hour', order_time) as hour
from customer_orders
group by hour
order by hour asc;

-- What was the volume of orders for each day of the week?
select 
  count(*) as total, 
  to_char(order_time, 'Day') as day_of_week
from customer_orders
group by day_of_week
order by day_of_week;
