SET search_path TO pizza_runner;


-- Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
-- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
-- What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

-- What are the standard ingredients for each pizza?
select 
  pr.pizza_id,
  pt.topping_name
from pizza_recipes pr
join pizza_toppings pt 
  on pt.topping_id = any(string_to_array(pr.toppings, ',')::int[]);

-- What was the most commonly added extra?
select count(*), extra_id
from (
select unnest(string_to_array(extras, ','))::int as extra_id
from customer_orders
where extras is not null
)
group by extra_id
order by count desc
limit 1;

-- What was the most common exclusion?
select count(*), exclu_id
from (
select unnest(string_to_array(exclusions, ','))::int as exclu_id
from customer_orders
where exclusions is not null
)
group by exclu_id
order by count desc
limit 1;

-- Generate an order item for each record in the customers_orders table in the format of one of the following:
-- Meat Lovers
-- Meat Lovers - Exclude Beef
-- Meat Lovers - Extra Bacon
-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
-- create or replace function desc_orders()
-- 	returns void
-- 	language plpgsql
-- 	as
-- $$
-- declare
-- get_commands CURSOR FOR SELECT * FROM customer_orders;
-- get_excludes CURSOR FOR SELECT topping_name FROM pizza_toppings WHERE topping_id = ANY(string_to_array(excludes, ',')::int[]);
-- get_extras CURSOR FOR SELECT topping_name FROM pizza_toppings WHERE topping_id = ANY(string_to_array(extras, ',')::int[]);
-- pizza_name text;
-- current_order_id INT;
-- current_topping_id INT;
-- begin
-- 	open get_commands;

-- 	loop
-- 		fetch get_commands into current_order_id;
-- 		exit when not found;
-- 		select pizza_name from pizza_names join 

-- end;
-- $$;
select desc_pizza();

select * 
from customer_orders c
join pizza_names n
on c.pizza_id = n.pizza_id;

select 
  pr.pizza_id,
  pt.topping_name,
  pz.pizza_name
from pizza_recipes pr
join pizza_toppings pt 
  on pt.topping_id = any(string_to_array(pr.toppings, ',')::int[])
join pizza_names pz
on pr.pizza_id = pz.pizza_id;

select
pn.pizza_name,
pt.topping_name as excludes,
c.order_id
from customer_orders c
join pizza_names pn
on c.pizza_id = pn.pizza_id
join pizza_toppings pt
on pt.topping_id = any(string_to_array(c.exclusions, ',')::int[]);

select
  c.order_id,
  c.pizza_id,
  pn.pizza_name,
  string_agg(pt.topping_name, ', ') as excludes
from customer_orders c
join pizza_names pn on c.pizza_id = pn.pizza_id
join pizza_toppings pt on pt.topping_id = any(string_to_array(c.exclusions, ',')::int[])
where c.order_id = 4 and c.pizza_id = 1
group by c.order_id, c.pizza_id, pn.pizza_name;

select order_id, co.pizza_id, exclusions, extras
from customer_orders co
join pizza_names pn
on co.pizza_id = pn.pizza_id;

select * from pizza_toppings
where topping_id in (1,2,3)