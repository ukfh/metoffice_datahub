SELECT dt,
       name,
       metric,
       hourkey,
       concat(date_time, ' UTC') date_time,
       ifnull(value, 0)          value
FROM staging.observations_long
where 1 = 1
  and name = 'gcp76x'
  and metric in ('t','h')
  and dt >= cast(SYSDATE() as date) - 8
order by date_time desc
;
