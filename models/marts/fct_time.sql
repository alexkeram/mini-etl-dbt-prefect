{{ config(
    materialized='incremental',
    unique_key=['customer_id','period'],
    on_schema_change='append_new_columns',
    incremental_strategy='delete+insert'
) }}

with base as (
  -- Time facts without bad customers
  select
    t.time_chunk_id as customer_id,
    t.period,
    t.minutes_spent
  from {{ ref('stg_market_time') }} t
  left join {{ ref('int_ids_to_remove') }} bad
    on t.time_chunk_id = bad.customer_id
  where bad.customer_id is null
),

delta as (
  select *
  from base
  {% if is_incremental() %}
    where period >= (
      select coalesce(max(period), '1900-01-01') from {{ this }}
    )
  {% endif %}
)

select * from delta
