SET search_path TO pizza_runner;

select 
array_cat(
array(
  select unnest(string_to_array(toppings, ',')::int[])
  except
  select unnest(string_to_array(exclusions, ',')::int[])
),
string_to_array(extras, ',')::int[]
) as ingredients,
order_id,co.pizza_id
from customer_orders co
join pizza_recipes pr
on co.pizza_id = pr.pizza_id
order by order_id,pizza_id;