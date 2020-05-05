import '../weather.dart';
import 'package:intl/intl.dart';
class WeatherData {
  String areaName;
  String temprature;
  String weatherMain;
  double windSpeed;
  String sunrise;
  String sunset;
  double humidity;

  WeatherData(
      {this.areaName = "",
      this.temprature = "",
      this.weatherMain = "",
      this.windSpeed = 0.0,
      this.sunrise = "",
      this.sunset = "",
      this.humidity = 0.0});

  WeatherData.fromWeather(Weather weather) {
    this.areaName = weather.areaName;
    this.temprature = weather.temperature.fahrenheit.round().toString();
    this.weatherMain = weather.weatherMain;
    this.windSpeed = weather.windSpeed;
    this.sunrise = DateFormat('hh:mm a').format(weather.sunrise);
    this.sunset = DateFormat('hh:mm a').format(weather.sunset);
    this.humidity = weather.humidity;

  }
}
