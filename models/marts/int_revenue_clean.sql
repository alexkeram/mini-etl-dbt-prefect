-- Cap revenue using global IQR (Q1/Q3 over all rows)
with r as (
  select *
  from {{ ref('stg_market_money') }}  -- state_id, period, revenue
),
iqr as (
  select
    quantile(revenue, 0.25) as q1,
    quantile(revenue, 0.75) as q3
  from r
),
capped as (
  select
    r.state_id,
    r.period,
    r.revenue,
    i.q1,
    i.q3,
    (i.q3 - i.q1) as iqr,
    (i.q3 + 1.5 * (i.q3 - i.q1)) as upper_bound
  from r cross join iqr i
)
select
  state_id,
  period,
  revenue
from capped
where revenue is not null
  and revenue <= upper_bound
