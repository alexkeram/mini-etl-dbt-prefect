-- Remove customers with any missing or zero revenue across known periods
with r as (
  select * from {{ ref('stg_market_money') }}
)
select
  state_id as customer_id
from r
group by state_id
having
  -- any of the three periods is NULL or 0
  sum(case when period = 'current_month'     and (revenue is null or revenue = 0) then 1 else 0 end) > 0
  or
  sum(case when period = 'prev_month'        and (revenue is null or revenue = 0) then 1 else 0 end) > 0
  or
  sum(case when period = 'prev_prev_month'   and (revenue is null or revenue = 0) then 1 else 0 end) > 0
