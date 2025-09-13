-- Normalize raw_money: rename columns to English and cast types
with src as (
    select * from {{ ref('raw_money') }}
)
select
    cast(id as bigint) as money_id,
    -- "Прибыль" -> replace comma with dot, then cast to DECIMAL
    cast(replace("Прибыль", ',', '.') as decimal(10,2)) as profit
from src
