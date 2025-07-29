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
  ingredient_list int[];
  get_orders cursor for select distinct order_id from customer_orders order by order_id asc;
  current_ingredient text;
  current_ingredient_count int;
begin
open get_orders;
loop
fetch get_orders into current_oid;
exit when not found;
raise notice 'Order number - %', current_oid;
select into ingredient_list array_agg(ing) as ingredients
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
  where order_id = current_oid
) sub;
description :='Ingredients : ';
  for current_ingredient_count, current_ingredient in
    select count(*), pt.topping_name
    from unnest(ingredient_list) as t(val)
    join pizza_toppings pt on t.val = pt.topping_id
    group by pt.topping_name
    order by pt.topping_name asc
  loop
	if current_ingredient_count > 1 then
	  description := description || current_ingredient || ' x' || current_ingredient_count || ', ';
	else
	  description := description || current_ingredient || ', ';
	end if;
  end loop;
  raise notice '%', description;


end loop;
close get_orders;
end;
$$;

select describe_ingredients();