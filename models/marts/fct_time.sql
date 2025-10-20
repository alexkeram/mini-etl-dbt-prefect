-- Time facts without bad customers
select
  t.time_chunk_id as customer_id,
  t.period,
  t.minutes_spent
from {{ ref('stg_market_time') }} t
left join {{ ref('int_ids_to_remove') }} bad
  on t.time_chunk_id = bad.customer_id
where bad.customer_id is null
