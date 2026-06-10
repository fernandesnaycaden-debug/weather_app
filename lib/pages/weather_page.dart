import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/service/weather_service.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  
  //api key
  final _weatherService = WeatherService(apiKey: 'api_Key');
  Weather? _weather;

  fetchWeather() async {

    String cityname = await _weatherService.getCurrentCityName();

  try {
    final weather = await _weatherService.getWeather(cityname);
    setState(() {
      _weather = weather;
    });
  }

  catch (e) {
    print(e);
  }
  }

  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/sunny.json';

    switch (mainCondition.toLowerCase()) {
      case 'sunny' :
      case 'clear' :
        return 'assets/sunny.json';
      case 'clouds' :
      case 'mist' :
      case 'haze' :
      case 'fog' :
      case 'smoke' :
        return 'assets/cloudy.json';
      case 'rain' :
      case 'drizzle' :
        return 'assets/rainy.json';
      case 'snow' :
        return 'assets/snowy.json';
      case 'thunderstorm' :
        return 'assets/thunderstorm.json';
      default :
        return 'assets/sunny.json';
    }
  }

  @override

  void initState(){
    super.initState();
    fetchWeather();
  }
  
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
      ),
      body: Center(
        child: Column (
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_weather?.cityName ?? 'Loading...'),

            Lottie.asset(getWeatherAnimation(_weather?.mainCondition)),

            Text('${_weather?.temperature.round()}°C'),

            Text(_weather?.mainCondition ?? '')
          ]
        ),
      ),
    );
  }
}
