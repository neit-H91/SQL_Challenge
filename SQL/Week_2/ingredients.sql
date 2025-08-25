SET search_path TO pizza_runner;

with ingredients_per_order as(
select 
array_cat(
array(
  select unnest(string_to_array(toppings, ',')::int[])
  except
  select unnest(string_to_array(exclusions, ',')::int[])
),
string_to_array(extras, ',')::int[]
) as ingredients
from customer_orders co
join pizza_recipes pr
on co.pizza_id = pr.pizza_id
where order_id = 4
)

select 
  i.ingredient_id,
  pt.topping_name,
  count(*) as nb,
  ipo.order_id
from ingredients_per_order ipo
cross join lateral unnest(ipo.ingredients) as i(ingredient_id)
join pizza_toppings pt
  on pt.topping_id = i.ingredient_id
group by order_id, pt.topping_name
order by nb desc;


select array_agg(ing) as ingredients
from (
  select unnest(
    array_cat(
      array(
        select unnest(string_to_array(toppings, ',')::int[])
        except
        select unnest(string_to_array(exclusions, ',')::int[])
      ),
      string_to_array(extras, ',')::int[]
    )
  ) as ing
  from customer_orders co
  join pizza_recipes pr
    on co.pizza_id = pr.pizza_id
  where order_id = 1
) sub;

select val, count(*), tp.topping_name
from unnest(array[8,10,1,5,2,6,3,8,10,1,5,2,6,3,11,9,7,6,12]) as t(val)
join pizza_toppings
on t.val = pt.topping_id
group by t.val, topping_name
order by count(*) desc;

select count(*), pt.topping_name
from unnest(array[8,10,1,5,2,6,3,8,10,1,5,2,6,3,11,9,7,6,12]) as t(val)
join pizza_toppings pt
  on t.val = pt.topping_id
group by pt.topping_name
order by topping_name asc;

