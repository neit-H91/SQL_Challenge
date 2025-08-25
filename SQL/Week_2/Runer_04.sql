SET search_path TO pizza_runner;

-- Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
-- customer_id
-- order_id
-- runner_id
-- rating
-- order_time
-- pickup_time 
-- Time between order and pickup
-- Delivery duration
-- Average speed
-- Total number of pizzas

-- If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
select sum(case when pizza_id = 1 then 12 end) + sum(case when pizza_id = 2 then 10 end) as total_made
from customer_orders;

-- What if there was an additional $1 charge for any pizza extras?
-- Add cheese is $1 extra
select sum(case when pizza_id = 1 then 12 end) + sum(case when pizza_id = 2 then 10 end) + sum(case when extras is not null then cardinality(string_to_array(extras,',')::int[]) end) as total_made
from customer_orders;

-- The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
create table rating(
	order_id int,
	customer_id int,
	runner_id int,
	rating int,
	primary key (order_id, runner_id)
)

-- If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
select sum(case when pizza_id = 1 then 12 end) + sum(case when pizza_id = 2 then 10 end) - sum(case when distance is not null then NULLIF(distance, 'null')::numeric * 0.3 end) as total_made 
from runner_orders r join customer_orders c on r.order_id = c.order_id;