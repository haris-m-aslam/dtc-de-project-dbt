{{ config(materialized='view') }}

with propertidata as 
(
  select *,
    row_number() over(partition by id, created_on) as rn
  from {{ source('staging','sell_data_partitioned') }}
  where id is not null 
)
select
    -- identifiers
    {{ dbt_utils.surrogate_key(['id', 'created_on']) }} as propertiid,
    cast(id as integer) as id,    
    cast(title as string) as title
from propertidata
where rn = 1


-- dbt build --m <model.sql> --var 'is_test_run: false'
{% if var('is_test_run', default=true) %}

  limit 100

{% endif %}
