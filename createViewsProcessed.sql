use processed;

create or replace view observations_long
AS
with observations_long
         as (select cast(obs_datetime as date) dt
                  , station_geohash            name
                  , 'v'                        metric
                  , hour(obs_datetime)         hourkey
                  , obs_datetime               date_time
                  , visibility                 value
             from processed.observations
             where 1 = 1
               and station_geohash = 'gcp76x'

             union all
             select cast(obs_datetime as date) dt
                  , station_geohash            name
                  , 't'                        metric
                  , hour(obs_datetime)         hourkey
                  , obs_datetime               date_time
                  , temperature                value
             from processed.observations
             where 1 = 1
               and station_geohash = 'gcp76x'
             union all
             select cast(obs_datetime as date) dt
                  , station_geohash            name
                  , 'h'                        metric
                  , hour(obs_datetime)         hourkey
                  , obs_datetime               date_time
                  , humidity                   value
             from processed.observations

             union all

             select cast(obs_datetime as date) dt
                  , station_geohash            name
                  , 'p'                        metric
                  , hour(obs_datetime)         hourkey
                  , obs_datetime               date_time
                  , mslp                       value
             from processed.observations

             union all

             select cast(obs_datetime as date) dt
                  , station_geohash            name
                  , 'w'                        metric
                  , hour(obs_datetime)         hourkey
                  , obs_datetime               date_time
                  , wind_speed                 value
             from processed.observations

             union all

             select cast(obs_datetime as date) dt
                  , station_geohash            name
                  , 'dp'                       metric
                  , hour(obs_datetime)         hourkey
                  , obs_datetime               date_time
                  , null                       value
             from processed.observations)
select dt, name, metric, hourkey, date_time, value
from observations_long
;