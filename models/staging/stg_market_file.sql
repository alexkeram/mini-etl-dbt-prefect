with src as (
  select * from {{ ref('raw_market_file') }}
),
clean as (
  select
    cast(id as bigint)                                         as customer_id,

    -- activity: snake_case
    case lower("Покупательская активность")
      when 'снизилась' then 'decreased'
      when 'выросла'   then 'increased'
      when 'прежний уровень' then 'stable'
      else lower("Покупательская активность")
    end                                                        as customer_activity,

    -- tier
    case lower("Тип сервиса")
      when 'премиум'  then 'premium'
      when 'стандарт' then 'standard'
      when 'стандартт'then 'standard'
      else lower("Тип сервиса")
    end                                                        as service_tier,

    -- boolean
    case lower("Разрешить сообщать")
      when 'да' then true
      when 'нет' then false
      else null
    end                                                        as allow_notifications,

    -- popular category
    case lower(cast("Популярная_категория" as varchar))
      when 'товары для детей' then 'for children'
      when 'техника для красоты и здоровья' then 'for beauty and health'
      when 'мелкая бытовая техника и электроника' then 'gadgets'
      when 'кухонная посуда' then 'kitchenware'
      when 'косметика и аксессуары' then 'cosmetics and accessories'
      when 'домашний текстиль' then 'home textiles'
      else null
    end                                                        as popular_category,
    cast("Длительность" as integer)                            as duration_days,
    cast(replace(replace(cast("Маркет_актив_6_мес" as varchar), ' ', ''), ',', '.') as decimal(10,2)) as marketing_activity_6m,
    cast(replace(replace(cast("Маркет_актив_тек_мес" as varchar), ' ', ''), ',', '.') as decimal(10,2)) as marketing_activity_curr_m,
    cast(replace(replace(cast("Акционные_покупки" as varchar), ' ', ''), ',', '.') as decimal(10,2)) as promo_purchases,

    cast("Средний_просмотр_категорий_за_визит" as integer)     as avg_categories_per_visit,
    cast("Неоплаченные_продукты_штук_квартал" as integer)      as unpaid_products_qtr,
    cast("Ошибка_сервиса" as integer)                          as service_error_flag,
    cast("Страниц_за_визит" as integer)                        as pages_per_visit
  from src
)
select * from clean
