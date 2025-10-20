-- Cleaned customer attributes
with f as (
  select * from {{ ref('stg_market_file') }}
),
bad as (
  select customer_id from {{ ref('int_ids_to_remove') }}
)
select
  f.*
from f
left join bad
  on f.customer_id = bad.customer_id
where bad.customer_id is null
