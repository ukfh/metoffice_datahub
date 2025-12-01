use staging;

drop table if exists obs_tmp;
create table if not exists obs_tmp
(
    observations json default null
)
;


drop table if exists observations;
create table if not exists observations
(
    report_date_str   varchar(40),
    report_date       datetime,
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
    pressure_tendency varchar(10),
    report_key        varchar(100),
    obs_key           varchar(100)
)
;

drop table if exists staging.weather_processed_t;
CREATE TABLE if not exists staging.weather_processed_t
(
    i         varchar(10),
    name      varchar(100),
    lat       double,
    lon       double,
    country   varchar(100),
    continent varchar(100),
    elevation varchar(10),
    daykey    varchar(10),
    hourkey   varchar(10),
    metric    varchar(10),
    value     varchar(10),
    year      integer,
    month     varchar(10),
    day       varchar(10),
    dt        varchar(10)
);