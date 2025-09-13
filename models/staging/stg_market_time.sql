with src as (
  select * from {{ ref('raw_market_time') }}
),
clean as (
  select
    cast(id as bigint)                           as customer_id,
    case lower("Период")
      when 'текущий_месяц' then 'current_month'
      when 'предыдущий_месяц' then 'prev_month'
      when 'препредыдущий_месяц' then 'prev_prev_month'
      when 'предыдцщий_месяц' then 'prev_month'
      else lower("Период")
    end                                          as period,
    cast("минут" as integer)                     as minutes_spent
  from src
)
select * from clean
