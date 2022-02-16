{{ config(materialized='view') }}

select
   -- identifiers
    {{ dbt_utils.surrogate_key(['dispatching_base_num', 'pickup_datetime'])}} as tripid,
    cast(dispatching_base_num as string) as dispatching_base_num,
    cast(pulocationid as integer) as  pickup_locationid,
    cast(dolocationid as integer) as dropoff_locationid,
    cast(affiliated_base_number as string) as affiliated_base_number,
    cast(sr_flag as integer) as sr_flag,

    -- timestamps
    cast(pickup_datetime as timestamp) as pickup_datetime,
    cast(dropoff_datetime as timestamp) as dropoff_datetime,

from {{ source('staging','fhv_tripdata_partitioned') }}

-- dbt build --m <model.sql> --var 'is_test_run: false'
{% if var('is_test_run', default=true) %}

limit 100

{% endif %}