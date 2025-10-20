-- Final wide table for notebooks / ML
with rev as (
  select
    customer_id,
    sum(case when period = 'current_month' then revenue end) as revenue_curr_m,
    sum(case when period = 'prev_month'    then revenue end) as revenue_prev_m,
    sum(case when period = 'prev_prev_month' then revenue end) as revenue_prev2_m
  from {{ ref('fct_revenue_clean') }}
  group by 1
),
tm as (
  select
    customer_id,
    sum(case when period = 'current_month' then minutes_spent end) as minutes_curr_m,
    sum(case when period = 'prev_month'    then minutes_spent end) as minutes_prev_m,
    sum(case when period = 'prev_prev_month' then minutes_spent end) as minutes_prev2_m
  from {{ ref('fct_time') }}
  group by 1
),
pf as (
  select customer_id, profit
  from {{ ref('fct_profit') }}
)
select
  d.*,
  r.revenue_curr_m, r.revenue_prev_m, r.revenue_prev2_m,
  t.minutes_curr_m, t.minutes_prev_m, t.minutes_prev2_m,
  p.profit
from {{ ref('dim_customer') }} d
left join rev r on d.customer_id = r.customer_id
left join tm  t on d.customer_id = t.customer_id
left join pf  p on d.customer_id = p.customer_id
