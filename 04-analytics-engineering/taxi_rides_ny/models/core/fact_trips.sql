{{ config(materialized="table") }}


with
    green_tripdata as (
        select
            {{ dbt_utils.generate_surrogate_key(['vendor_id', 'pickup_datetime', 'pickup_location_id']) }} as trip_id,
            vendor_id,
            rate_code_id,
            pickup_location_id,
            dropoff_location_id,
            pickup_datetime,
            dropoff_datetime,
            store_and_fwd_flag,
            passenger_count,
            trip_distance,
            fare_amount,
            extra,
            mta_tax,
            tip_amount,
            tolls_amount,
            improvement_surcharge,
            total_amount,
            payment_type,
            'Green' as service_type
        from {{ ref("stg_green_tripdata") }}
    ),
    yellow_tripdata as (
        select
            {{ dbt_utils.generate_surrogate_key(['vendor_id', 'pickup_datetime', 'pickup_location_id']) }} as trip_id,
            vendor_id,
            rate_code_id,
            pickup_location_id,
            dropoff_location_id,
            pickup_datetime,
            dropoff_datetime,
            store_and_fwd_flag,
            passenger_count,
            trip_distance,
            fare_amount,
            extra,
            mta_tax,
            tip_amount,
            tolls_amount,
            improvement_surcharge,
            total_amount,
            payment_type,
            'Yellow' as service_type
        from {{ ref("stg_yellow_tripdata") }}
    ),
    tripsunion as (
        select *
        from green_tripdata
        union all
        select *
        from yellow_tripdata
    ),
    dim_zones as (select * from {{ ref("dim_zones") }} where borough != 'Unknown')
select
    tripsunion.*,
    pickup_zone.locationid as pickup_zone_locationid,
    pickup_zone.borough as pickup_zone_borough,
    pickup_zone.zone as pickup_zone_zone,
    pickup_zone.service_zone as pickup_zone_service_zone,
    dropoff_zone.locationid as dropoff_zone_locationid,
    dropoff_zone.borough as dropoff_zone_borough,
    dropoff_zone.zone as dropoff_zone_zone,
    dropoff_zone.service_zone as dropoff_zone_service_zone
from tripsunion
inner join
    dim_zones as pickup_zone on tripsunion.pickup_location_id = pickup_zone.locationid
inner join
    dim_zones as dropoff_zone on tripsunion.pickup_location_id = dropoff_zone.locationid
