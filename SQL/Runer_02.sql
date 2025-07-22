SET search_path TO pizza_runner;

-- cleaning tables
-- couldve used set duration = substring(duration from 1 for 2);
UPDATE runner_orders
SET distance = REPLACE(distance, 'km', '');

update runner_orders
set duration = replace(duration, 'minute','');

update runner_orders
set duration = replace(duration, 'minutes','');

update runner_orders
set duration = replace(duration, 'min','');

update runner_orders
set duration = replace(duration, 'mins','');

-- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
select date_trunc('week', registration_date) as week_start, count(*) as runners_signed_up
from runners
group by week_start
order by week_start;

-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
select avg(to_timestamp(pickup_time, 'YYYY-MM-DD HH24:MI:SS') - order_time) as moyenne
from runner_orders r
join customer_orders c
on r.order_id = c.order_id
where cancellation = ''
and runner_id = 1;

-- Is there any relationship between the number of pizzas and how long the order takes to prepare?
select count(pizza_id), sum(extract(epoch from (to_timestamp(pickup_time, 'YYYY-MM-DD HH24:MI:SS') - order_time))) as total_seconds, c.order_id
from customer_orders c
join runner_orders r
on c.order_id = r.order_id
where cancellation = ''
group by c.order_id;

-- What was the average distance travelled for each customer?
select avg(cast(distance as float)), customer_id
from runner_orders r
join customer_orders c
on r.order_id = c.order_id
where cancellation is null
group by customer_id;

-- What was the difference between the longest and shortest delivery times for all orders?
select min(cast(duration as float)) - max(cast(duration as float)) as difference
from runner_orders
where cancellation is null;

-- What was the average speed for each runner for each delivery and do you notice any trend for these values?
select cast(distance as float) / cast(duration as float)*60 as speed, runner_id, order_id
from runner_orders
where cancellation is null
order by runner_id desc;

-- What is the successful delivery percentage for each runner?
select count(case when cancellation is null then 1 end)::numeric / count(*) as ratio, runner_id
from runner_orders
group by runner_id