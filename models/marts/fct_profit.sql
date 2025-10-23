{{ config(
    materialized='incremental',
    unique_key='customer_id',
    on_schema_change='append_new_columns',
    incremental_strategy='delete+insert'
) }}

with base as (
  -- Profit facts without bad customers
  select
    m.money_id as customer_id,
    m.profit
  from {{ ref('stg_money') }} m
  left join {{ ref('int_ids_to_remove') }} bad
    on m.money_id = bad.customer_id
  where bad.customer_id is null
),

delta as (
  select *
  from base
  {% if is_incremental() %}
    -- Increments
    where not exists (
      select 1
      from {{ this }} t
      where t.customer_id = base.customer_id
    )
  {% endif %}
)

select * from delta
