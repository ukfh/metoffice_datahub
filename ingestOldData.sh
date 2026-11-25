#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
data_file="$script_dir/allWeather_20251122.tsv"

if [[ ! -f "$data_file" ]]; then
    printf 'Data file not found: %s\n' "$data_file" >&2
    exit 1
fi

sql_file="$(printf '%s' "$data_file" | sed "s/'/''/g")"

mysql --host=pidata02 --user=monitor --local-infile=1 --database=STAGING <<SQL
LOAD DATA LOCAL INFILE '$sql_file'
INTO TABLE WEATHER_PROCESSED_T
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
(I, NAME, LAT, LON, COUNTRY, CONTINENT, ELEVATION, DAYKEY, HOURKEY,
 METRIC, VALUE, YEAR, MONTH, DAY, @DT)
SET DT = TRIM(@DT);
SQL
