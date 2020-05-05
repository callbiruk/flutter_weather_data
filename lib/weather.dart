
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenWeatherAPIException implements Exception {
  String _cause;
  OpenWeatherAPIException(this._cause);

  String toString() => '${this.runtimeType} - $_cause';
}

class Temperature {
  double _kelvin;

  Temperature(this._kelvin);

  double get kelvin => _kelvin;

  double get celsius => _kelvin - 273.15;

  double get fahrenheit => _kelvin * (9 / 5) - 459.67;

  String toString() => '${celsius.toStringAsFixed(1)} Celsius';
}

double _unpackDouble(Map<String, dynamic> M, String k) {
  if (M != null) {
    if (M.containsKey(k)) {
      return M[k] + 0.0;
    }
  }
  return 0.0;
}

String _unpackString(Map<String, dynamic> M, String k) {
  if (M != null) {
    if (M.containsKey(k)) {
      return M[k];
    }
  }
  return "";
}

DateTime _unpackDate(Map<String, dynamic> M, String k) {
  if (M != null) {
    if (M.containsKey(k)) {
      int millis = M[k] * 1000;
      return DateTime.fromMillisecondsSinceEpoch(millis);
    }
  }
  return null;
}
int _unpackWeekday(Map<String, dynamic> M, String k) {
  if (M != null) {
    if (M.containsKey(k)) {
      int millis = M[k] * 1000;
      return DateTime.fromMillisecondsSinceEpoch(millis).weekday;
    }
  }
  return null;
}

Temperature _unpackTemperature(Map<String, dynamic> M, String k) {
  double kelvin = _unpackDouble(M, k);
  return Temperature(kelvin);
}

class Weather {
  String _country, _areaName, _weatherMain, _weatherDescription, _weatherIcon;
  Temperature _temperature, _tempMin, _tempMax;
  DateTime _date, _sunrise, _sunset;
  int _weekday;
  double _latitude,
      _longitude,
      _pressure,
      _windSpeed,
      _windDegree,
      _humidity,
      _cloudiness,
      _rainLastHour,
      _rainLast3Hours,
      _snowLastHour,
      _snowLast3Hours;

  Weather(Map<String, dynamic> weatherData) {
    Map<String, dynamic> main = weatherData['main'];
    Map<String, dynamic> coord = weatherData['coord'];
    Map<String, dynamic> sys = weatherData['sys'];
    Map<String, dynamic> wind = weatherData['wind'];
    Map<String, dynamic> clouds = weatherData['clouds'];
    Map<String, dynamic> rain = weatherData['rain'];
    Map<String, dynamic> snow = weatherData['snow'];
    Map<String, dynamic> weather = weatherData['weather'][0];

    _latitude = _unpackDouble(coord, 'lat');
    _longitude = _unpackDouble(coord, 'lon');

    _country = _unpackString(sys, 'country');
    _sunrise = _unpackDate(sys, 'sunrise');
    _sunset = _unpackDate(sys, 'sunset');

    _weatherMain = _unpackString(weather, 'main');
    _weatherDescription = _unpackString(weather, 'description');
    _weatherIcon = _unpackString(weather, 'icon');

    _temperature = _unpackTemperature(main, 'temp');
    _tempMin = _unpackTemperature(main, 'temp_min');
    _tempMax = _unpackTemperature(main, 'temp_max');
    _humidity = _unpackDouble(main, 'humidity');
    _pressure = _unpackDouble(main, 'pressure');

    _windSpeed = _unpackDouble(wind, 'speed');
    _windDegree = _unpackDouble(wind, 'deg');

    _cloudiness = _unpackDouble(clouds, 'all');

    _rainLastHour = _unpackDouble(rain, '1h');
    _rainLast3Hours = _unpackDouble(rain, '3h');

    _snowLastHour = _unpackDouble(snow, '1h');
    _snowLast3Hours = _unpackDouble(snow, '3h');

    _areaName = _unpackString(weatherData, 'name');
    _date = _unpackDate(weatherData, 'dt');
    _weekday = _unpackWeekday(weatherData, 'dt');
  }

  String toString() {
    return '''
    Date: $_date
    Weather: $_weatherMain, $_weatherDescription
    Temp: $_temperature, Temp (min): $_tempMin, Temp (max): $_tempMax
    Sunrise: $_sunrise, Sunset: $_sunset
    ''';
  }

  /// A long description of the weather
  String get weatherDescription => _weatherDescription;

  /// A brief description of the weather
  String get weatherMain => _weatherMain;

  /// A brief description of the weather
  String get weatherIcon => _weatherIcon;

  /// The level of cloudiness in Okta (0-9 scale)
  double get cloudiness => _cloudiness;

  /// Wind direction in degrees
  double get windDegree => _windDegree;

  /// Wind speed in m/s
  double get windSpeed => _windSpeed;

  /// Max [Temperature]. Available as Kelvin, Celsius and Fahrenheit.
  Temperature get tempMax => _tempMax;

  /// Min [Temperature]. Available as Kelvin, Celsius and Fahrenheit.
  Temperature get tempMin => _tempMin;

  /// Mean [Temperature]. Available as Kelvin, Celsius and Fahrenheit.
  Temperature get temperature => _temperature;

  /// Pressure in Pascal
  double get pressure => _pressure;

  /// Humidity in percent
  double get humidity => _humidity;

  /// Longitude of the weather observation
  double get longitude => _longitude;

  /// Latitude of the weather observation
  double get latitude => _latitude;

  /// Date of the weather observation
  DateTime get date => _date;

  /// Week Day of the date
  int get weekday => _weekday;

  /// Timestamp of sunset
  DateTime get sunset => _sunset;

  /// Timestamp of sunrise
  DateTime get sunrise => _sunrise;

  /// Name of the area, ex Mountain View, or Copenhagen Municipality
  String get areaName => _areaName;

  /// Country code, ex US or DK
  String get country => _country;

  /// Rain fall last hour measured in volume
  double get rainLastHour => _rainLastHour;

  /// Rain fall last 3 hours measured in volume
  double get rainLast3Hours => _rainLast3Hours;

  /// Rain fall last 3 hours measured in volume
  double get snowLastHour => _snowLastHour;

  /// Rain fall last 3 hours measured in volume
  double get snowLast3Hours => _snowLast3Hours;
}

/// Plugin for fetching weather data in JSON.
class WeatherStation {
  String _apiKey;
  String _long;
  String _lat; 
  String _zipCode;
  static const String FORECAST = 'forecast';
  static const String WEATHER = 'weather';

  WeatherStation(this._apiKey, this._zipCode);

  /// Fetch current weather based on geographical coordinates
  /// Result is JSON.
  /// For API documentation, see: https://openweathermap.org/current
  Future<Weather> currentWeather() async {
    try {
      Map<String, dynamic> currentWeather = await _requestOpenWeatherAPI(WEATHER);
      return Weather(currentWeather);
    } catch (exception) {
      print(exception);
    }
    return null;
  }

  /// Fetch current weather based on geographical coordinates.
  /// Result is JSON.
  /// For API documentation, see: https://openweathermap.org/forecast5
  Future<List<Weather>> fiveDayForecast() async {
    List<Weather> forecasts = new List<Weather>();
    try {
      Map<String, dynamic> jsonForecasts = await _requestOpenWeatherAPI(FORECAST);
      List<dynamic> forecastsJson = jsonForecasts['list'];
      forecasts = forecastsJson.map((w) => Weather(w)).toList();
    } catch (exception) {
      print(exception);
    }
    return forecasts;
  }

  Future<Map<String, dynamic>> _requestOpenWeatherAPI(String tag) async {

    /// Build HTTP get url by passing the required parameters
    String url = 'http://api.openweathermap.org/data/2.5/' +
        '$tag?' +
        // 'lat=$_lat&' +
        // 'lon=$_long&' +
        'zip=$_zipCode&' +
        'appid=$_apiKey';

    /// Send HTTP get response with the url
    http.Response response = await http.get(url);

    /// Perform error checking on response:
    /// Status code 200 means everything went well
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonBody = json.decode(response.body);
      return jsonBody;
    }

  }
}