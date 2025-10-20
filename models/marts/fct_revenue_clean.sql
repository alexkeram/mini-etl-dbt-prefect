-- Filter revenue by IQR and drop bad customers
select
  rc.state_id as customer_id,
  rc.period,
  rc.revenue
from {{ ref('int_revenue_clean') }} rc
left join {{ ref('int_ids_to_remove') }} bad
  on rc.state_id = bad.customer_id
where bad.customer_id is null
