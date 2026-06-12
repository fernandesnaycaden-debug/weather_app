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
  // api key
  final _weatherService = WeatherService(apiKey: 'api_Key');
  Weather? _weather;

  BoxDecoration getWeatherBackground(Weather? weather) {
    if (weather == null) {
      return const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.lightBlueAccent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      );
    }

    bool isNight = weather.isNight;

    // Handling the Night condition
    if (isNight) {
      switch (weather.mainCondition.toLowerCase()) {
        case 'thunderstorm':
        case 'rain':
        case 'drizzle':
          return const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            ),
          );
        case 'clear':
        default:
          return const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0F2027), Color(0xFF203A43)],
            ),
          );
      }
    }

    // Handling the day condition
    switch (weather.mainCondition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2980B9), Color(0xFF6DD5FA), Color(0xFFFFFFFF)],
          ),
        );
      case 'clouds':
      case 'mist':
      case 'haze':
      case 'fog':
      case 'smoke':
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF757F9A), Color(0xFFD7DDE8)],
          ),
        );
      case 'rain':
      case 'drizzle':
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4B6CB7), Color(0xFF182848)],
          ),
        );
      case 'thunderstorm':
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF141E30), Color(0xFF243B55)],
          ),
        );
      case 'snow':
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE6DADA), Color(0xFF274046)],
          ),
        );
      default:
        return const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
          ),
        );
    }
  }

  fetchWeather() async {
    String cityname = await _weatherService.getCurrentCityName();

    try {
      final weather = await _weatherService.getWeather(cityname);
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      print(e);
    }
  }

  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/sunny.json';

    switch (mainCondition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return 'assets/sunny.json';
      case 'clouds':
      case 'mist':
      case 'haze':
      case 'fog':
      case 'smoke':
        return 'assets/cloudy.json';
      case 'rain':
      case 'drizzle':
        return 'assets/rainy.json';
      case 'snow':
        return 'assets/snowy.json';
      case 'thunderstorm':
        return 'assets/thunderstorm.json';
      default:
        return 'assets/sunny.json';
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    // Check if it's night to change app bar/text color themes dynamically
    bool isNight = _weather?.isNight ?? false;
    Color textColor = isNight ? Colors.white70 : Colors.black87;
    Color mainTemperatureColor = isNight ? Colors.white : Colors.black87;

    return Scaffold(
      // Extend the body behind the AppBar so the gradient covers the full screen
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Weather App'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textColor, // Adjusts back button/text color automatically
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: getWeatherBackground(_weather), // Dynamic Background applied here
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // City Name
                Text(
                  _weather?.cityName.toUpperCase() ?? 'LOADING...',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 20),

                // Weather Animation
                Lottie.asset(
                  getWeatherAnimation(_weather?.mainCondition),
                  height: 240, // Constrain size nicely
                ),

                const SizedBox(height: 20),

                // Temperature
                Text(
                  _weather != null ? '${_weather!.temperature.round()}°C' : '',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w300,
                    color: mainTemperatureColor,
                  ),
                ),

                // Condition Text
                Text(
                  _weather?.mainCondition.toUpperCase() ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}