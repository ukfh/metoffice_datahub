SELECT dt,
name,
              metric,
hourkey,
concat(date_time, ' UTC') 		            date_time,

ifnull(value,0)			           value
				   FROM staging.observations_long
				   where 1 = 1
				   and name = 'gcp76x'
				   and metric = 't'
				   order by date_time desc
				   ;
