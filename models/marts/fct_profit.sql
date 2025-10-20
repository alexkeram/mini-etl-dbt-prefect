-- Profit facts without bad customers
select
  m.money_id as customer_id,
  m.profit
from {{ ref('stg_money') }} m
left join {{ ref('int_ids_to_remove') }} bad
  on m.money_id = bad.customer_id
where bad.customer_id is null
