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

create or replace function describe_pizza_orders()
returns void
language plpgsql
as
$$
declare
get_orders cursor for select pizza_id, exclusions, extras from customer_orders;
current_pid int;
current_pizza_name text;
current_exclude text;
current_extra text;
description text;
topping_names text;
begin
open get_orders;
loop 
description := '';
fetch get_orders into current_pid,current_exclude,current_extra;
exit when not found;
select pizza_name into current_pizza_name from pizza_names where pizza_id = current_pid;
description := description || current_pizza_name;
if current_exclude is not null then
select string_agg(topping_name, ', ') into topping_names from pizza_toppings WHERE topping_id = ANY(string_to_array(current_exclude, ',')::int[]);
description := description || ' Excludes ' || topping_names;
end if;
if current_extra is not null then
select string_agg(topping_name, ', ') into topping_names from pizza_toppings WHERE topping_id = ANY(string_to_array(current_extra, ',')::int[]);
description := description || ' Extras ' || topping_names;
end if;
raise notice '%', description;
end loop;
close get_orders;
end;
$$;



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
where topping_id in (1,2,3);