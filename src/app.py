import os
import requests
from datetime import datetime, timedelta
import json
import json_logging
import logging
import sys

# log is initialized without a web framework name
json_logging.init_non_web(enable_json=True)

logger = logging.getLogger("weather-data-download")
logger.setLevel(logging.INFO)
logger.addHandler(logging.StreamHandler(sys.stdout))

CITY_CODE = os.getenv('CITY_CODE')
OPEN_WEATHER_API_KEY = os.getenv('OPEN_WEATHER_API_KEY')
OPEN_WEATHER_API = os.getenv('OPEN_WEATHER_API')


def download_city_next_hour_weather_data():
    """
    Download weather data for city
    """
    start_time = datetime.now()
    end_time = (start_time + timedelta(hours=1))

    requests_params = {'id': CITY_CODE, 'appid': OPEN_WEATHER_API_KEY}

    response = requests.get(url=OPEN_WEATHER_API, params=requests_params)

    logger.info(msg='Response status ' + str(response.status_code))

    city_weather = json.loads(response.text)['main']

    is_data_valid = validate_weather_data(city_weather)
    if not is_data_valid:
        logger.error("Data is missing for this hour.")


def validate_weather_data(city_weather):

    required_fields = ['temp', 'temp_min', 'temp_max', 'pressure', 'humidity']

    is_data_valid = True
    for required_field in required_fields:
        if required_field not in city_weather:
            is_data_valid = False

    return is_data_valid


def lambda_handler(event, context):
    logger.info(event)
    download_city_next_hour_weather_data()
