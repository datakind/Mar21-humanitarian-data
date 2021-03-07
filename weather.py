import requests
import json
from datetime import datetime
import pytz

def simple_get_weather(lat, lon, lang, api_key):
    '''
    Takes in lat, lon, lang, and api_key for the openweathermap API. Outputs a dictionary structure that can be loaded in via json.
    
    Total output of function is a dictionary, describing current and hourly weather (48 hours prior to the query).
    
    Need to update function so it can do more than one call. Also, update function so it can take in different units for temp.
    
    '''
    #Build URL and grab weather data
    url = 'https://api.openweathermap.org/data/2.5/onecall?lat={}&lon={}&units={}&lang={}&appid={}'.format(lat, lon, 'metric', lang, api_key)
    page = requests.get(url)
    weather_data = json.loads(page.text)
    
    #Go through current and hourly weather data and format dates correctly
    for curr_hour in ['current', 'hourly']:
        if curr_hour == 'current':
            for time in ['dt', 'sunrise', 'sunset']:
                helper = datetime.utcfromtimestamp(weather_data[curr_hour][time])
                weather_data[curr_hour][time] = pytz.utc.localize(helper).strftime('%Y-%m-%d %H:%M:%S')
        else:
            for el in weather_data[curr_hour]:
                helper = datetime.utcfromtimestamp(el['dt'])
                el['dt'] = pytz.utc.localize(helper).strftime('%Y-%m-%d %H:%M:%S')
    
    return weather_data

