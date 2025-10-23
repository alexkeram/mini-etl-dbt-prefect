{{ config(
    materialized='incremental',
    unique_key=['customer_id','period'],
    on_schema_change='append_new_columns',
    incremental_strategy='delete+insert'
) }}

with base as (
  -- Filter revenue by IQR and drop bad customers
  select
    rc.state_id as customer_id,
    rc.period,
    rc.revenue
  from {{ ref('int_revenue_clean') }} rc
  left join {{ ref('int_ids_to_remove') }} bad
    on rc.state_id = bad.customer_id
  where bad.customer_id is null
),

delta as (
  select *
  from base
  {% if is_incremental() %}
    -- Just last periods
    where period >= (
      select coalesce(max(period), '1900-01-01') from {{ this }}
    )
  {% endif %}
)

select * from delta
