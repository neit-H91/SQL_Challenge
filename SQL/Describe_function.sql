SET search_path TO pizza_runner;

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

select describe_pizza_orders()