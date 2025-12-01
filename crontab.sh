MAILTO="uliharder@gmail.com"
MAILFROM="uliharder@gmail.com"

# old weather data
15 1,5,9,13,17,21 * * * /home/uh/weather/weather/pipeline.sh
#30 0,12 * * * ~/bin/get-all-forecast.sh
#0  0,12 * * * ~/bin/get-all-observation.sh

# new weather data
5  0,8,16 * * * /home/uh/weather/metoffice_datahub/getObs.sh

# urls & tor data
0 0,2,4,6,8,10,12,14,16,18,20,22 * * * /home/uh/urls/bin/getUrl.sh
0 0 * * * ~/torData/bin/getTor.sh

#duckdns
#*/5 * * * * ~/duckdns/duck.sh >/dev/null 2>&1
