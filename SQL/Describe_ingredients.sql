SET search_path TO pizza_runner;

create or replace function describe_ingredients()
returns void
language plpgsql
as
$$
declare
  current_oid int;
  description text;
  ingredient_counts record;
  ingredient_list text := '';
  get_orders cursor for select distinct order_id from customer_orders;
begin
  open get_orders;
  loop
    fetch get_orders into current_oid;
    exit when not found;

    -- Pour chaque order_id, on récupère les ingrédients filtrés et comptés
    ingredient_list := (
      select string_agg(counts || ' ' || name, ', ' order by name)
      from (
        select count(*) as counts, pt.topping_name as name
        from (
          select unnest(array_cat(
            string_to_array(pr.toppings, ',')::int[],
            string_to_array(co.extras, ',')::int[]
          )) as topping_id,
          string_to_array(co.exclusions, ',')::int[] as exclusions
          from customer_orders co
          join pizza_recipes pr on co.pizza_id = pr.pizza_id
          where co.order_id = current_oid
        ) sub
        join pizza_toppings pt on pt.topping_id = sub.topping_id
        where not topping_id = any(sub.exclusions)
        group by pt.topping_name
      ) counts
    );

    description := 'Order ' || current_oid || ': ' || coalesce(ingredient_list, 'No ingredients');

    raise notice '%', description;
  end loop;
  close get_orders;
end;
$$;

select order_id from customer_orders;

select *
from (
  select 
    string_to_array(concat_ws(',', toppings, extras),',') as ingredients,
    exclusions
  from customer_orders co
  join pizza_recipes pr on pr.pizza_id = co.pizza_id
  where order_id = 4
) sub;

select
  co.order_id,
  unnest(
    string_to_array(concat_ws(',', toppings, extras),',')
  ) as ingredient
from customer_orders co
join pizza_recipes pr on pr.pizza_id = co.pizza_id
where co.order_id = 4;
-- and not (
--   unnest(
--     string_to_array(concat_ws(',', toppings, extras),',')
--   ) = any(string_to_array(co.exclusions, ','))
-- )

with test_ingredients as (
	select
	  co.order_id,
	  array_agg(unnest_ingredients) as ingredients
	from customer_orders co
	join pizza_recipes pr on pr.pizza_id = co.pizza_id
	cross join lateral unnest(
	    string_to_array(concat_ws(',', pr.toppings, co.extras), ',')
	) as t(unnest_ingredients)
	group by co.order_id;
)
