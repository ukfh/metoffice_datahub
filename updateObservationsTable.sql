use processed;

truncate observations;

insert into observations
with deduped_observations as (select ROW_NUMBER() OVER (partition by obs_key order by report_key) AS num,
                                     report_date_str,
                                     report_date,
                                     station_geohash,
                                     mslp,
                                     obs_datetime_str,
                                     obs_datetime,
                                     visibility,
                                     humidity,
                                     wind_speed,
                                     temperature,
                                     weather_code,
                                     wind_direction,
                                     pressure_tendency,
                                     report_key,
                                     obs_key
                              from staging.observations)
select station_geohash,
       mslp,
       obs_datetime_str,
       obs_datetime,
       visibility,
       humidity,
       wind_speed,
       temperature,
       weather_code,
       wind_direction,
       pressure_tendency
from deduped_observations
where 1 = 1
  and num = 1
;



