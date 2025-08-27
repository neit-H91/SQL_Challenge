set search_path to foodie_fi;

-- Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.
-- Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!

-- How many customers has Foodie-Fi ever had?
select count(distinct customer_id)
from subscriptions;

-- What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
select count(*), date_trunc('month', start_date) from subscriptions
where plan_id = 0
group by date_trunc('month', start_date)
order by date_trunc;

-- What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
select count(*), plan_id
from subscriptions
where start_date > '2020-12-31'
group by plan_id;

-- What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
with first_churn as (
  select distinct on (customer_id) customer_id, plan_id
  from subscriptions
  where plan_id = 4
  order by customer_id, start_date
)
select
	(select count(distinct customer_id) from subscriptions) as total_customers,
	count(*) as churned_customers,
       round(100.0 * count(*) / (select count(distinct customer_id) from subscriptions), 1) as churned_pct
from first_churn;

-- How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
with subs as (
  select 
    customer_id,
    plan_id,
    start_date,
    lead(plan_id) over(partition by customer_id order by start_date) as next_plan
  from subscriptions
)
select count(case when next_plan = 4 then 1 end) as total_churned,
round(count(case when next_plan = 4 then 1 end)::numeric / count(*)::numeric * 100) as churn_ratio
from subs;

-- What is the number and percentage of customer plans after their initial free trial?
select count(*)
from subscriptions;

-- How many customers have upgraded to an annual plan in 2020?
select count(*) from subscriptions
where start_date between '2020-01-01' and '2020-12-31'
and plan_id = 3;

-- How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
with trial as (
  select customer_id, start_date as trial_date
  from subscriptions
  where plan_id = 0
),
annual as (
  select customer_id, start_date as annual_date
  from subscriptions
  where plan_id = 3
)
select 
  round(avg(annual.annual_date - trial.trial_date), 1) as avg_days_to_annual
from annual
join trial using (customer_id);


-- Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
with trial as (
  select customer_id, start_date as trial_date
  from subscriptions
  where plan_id = 0
),
annual as (
  select customer_id, start_date as annual_date
  from subscriptions
  where plan_id = 3
),
diffs as (
  select 
    a.customer_id,
    a.annual_date - t.trial_date as days_to_annual
  from annual a
  join trial t using (customer_id)
)
select 
  (floor((days_to_annual - 1) / 30) * 30 + 1) as bucket_start,
  (floor((days_to_annual - 1) / 30) * 30 + 30) as bucket_end,
  count(*) as customers
from diffs
group by floor((days_to_annual - 1) / 30)
order by bucket_start;

-- How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
with subs as (
  select 
    customer_id,
    plan_id,
    start_date,
    lead(plan_id) over(partition by customer_id order by start_date) as next_plan
  from subscriptions
)
select count(*) as downgraded_customers
from subs
where plan_id = 2   -- pro monthly
  and next_plan = 1 -- basic monthly
  and extract(year from start_date) = 2020;
