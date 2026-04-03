create schema if not exists processed;
use processed;

# drop table observations;

create table if not exists observations
(
    station_geohash   varchar(10),
    mslp              integer,
    obs_datetime_str  varchar(40),
    obs_datetime      datetime,
    visibility        double,
    humidity          integer,
    wind_speed        double,
    temperature       double,
    weather_code      integer,
    wind_direction    varchar(10),
    pressure_tendency varchar(10)
)
;