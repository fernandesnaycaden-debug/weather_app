import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  // New Search & Favorites State Variables
  bool _isLoading = false;
  List<String> _favorites = [];
  final _searchController = TextEditingController();
  late SharedPreferences _prefs;

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

  // Initialization: SharedPreferences & load last saved/GPS weather
  Future<void> _initPrefsAndLoadData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _prefs = await SharedPreferences.getInstance();
      setState(() {
        _favorites = _prefs.getStringList('favorites') ?? [];
      });
      
      String? lastCity = _prefs.getString('last_city');
      if (lastCity != null && lastCity.isNotEmpty) {
        await fetchWeather(lastCity);
      } else {
        await fetchWeather();
      }
    } catch (e) {
      debugPrint("Error initializing preferences: $e");
      await fetchWeather();
    }
  }

  // Fetch Weather - accepts optional city name parameter
  Future<void> fetchWeather([String? cityname]) async {
    setState(() {
      _isLoading = true;
    });

    try {
      String nameToFetch = cityname ?? '';
      if (nameToFetch.isEmpty) {
        nameToFetch = await _weatherService.getCurrentCityName();
      }

      if (nameToFetch.isNotEmpty) {
        final weather = await _weatherService.getWeather(nameToFetch);
        setState(() {
          _weather = weather;
          _isLoading = false;
        });
        
        // Save as last loaded city
        if (mounted) {
          await _prefs.setString('last_city', weather.cityName);
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching weather: $e");
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load weather data: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Helper to format current date and time elegantly
  String _getFormattedDate() {
    final now = DateTime.now();
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    String weekday = weekdays[now.weekday - 1];
    String month = months[now.month - 1];
    int day = now.day;
    
    int hour = now.hour;
    String ampm = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    String minute = now.minute.toString().padLeft(2, '0');
    
    return '$weekday, $month $day • $hour:$minute $ampm';
  }

  // Toggle Favorite state
  Future<void> _toggleFavorite(String city) async {
    final cityUpper = city.toUpperCase();
    setState(() {
      if (_favorites.contains(cityUpper)) {
        _favorites.remove(cityUpper);
      } else {
        _favorites.add(cityUpper);
      }
    });
    await _prefs.setStringList('favorites', _favorites);
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
    _initPrefsAndLoadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Search & Favorites bottom sheet
  void _showSearchBottomSheet(BuildContext context) {
    _searchController.clear();
    Color textColor = Colors.white;
    Color subTextColor = Colors.white70;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF0F2027),
                      Color(0xFF203A43),
                      Color(0xFF2C5364),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white30,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Search City',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      style: GoogleFonts.poppins(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Enter city name...',
                        hintStyle: GoogleFonts.poppins(color: Colors.white38),
                        prefixIcon: const Icon(Icons.search, color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.08),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Colors.lightBlueAccent,
                            width: 1.5,
                          ),
                        ),
                      ),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          Navigator.pop(context);
                          fetchWeather(value.trim());
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'FAVORITE CITIES',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                            color: subTextColor,
                          ),
                        ),
                        if (_favorites.isNotEmpty)
                          Icon(
                            Icons.favorite,
                            color: Colors.redAccent.withValues(alpha: 0.8),
                            size: 16,
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_favorites.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Center(
                          child: Text(
                            'No favorite cities added yet',
                            style: GoogleFonts.poppins(
                              color: Colors.white38,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    else
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 250),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _favorites.length,
                          itemBuilder: (context, index) {
                            final city = _favorites[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                title: Text(
                                  city,
                                  style: GoogleFonts.poppins(
                                    color: textColor,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () async {
                                    await _toggleFavorite(city);
                                    setSheetState(() {});
                                  },
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  fetchWeather(city);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isNight = _weather?.isNight ?? false;
    Color textColor = isNight ? Colors.white70 : Colors.black87;
    Color mainTemperatureColor = isNight ? Colors.white : Colors.black87;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Weather App',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: textColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchBottomSheet(context),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: getWeatherBackground(_weather),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on,
                  color: textColor.withValues(alpha: 0.6),
                  size: 24,
                ),
                const SizedBox(height: 8),

                // City name with favorite heart button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 48), // Balancing spacer
                    Expanded(
                      child: Text(
                        _weather?.cityName.toUpperCase() ?? 'LOADING...',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 3,
                          color: textColor,
                        ),
                      ),
                    ),
                    if (_weather != null)
                      IconButton(
                        icon: Icon(
                          _favorites.contains(_weather!.cityName.toUpperCase())
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: _favorites.contains(_weather!.cityName.toUpperCase())
                              ? Colors.redAccent
                              : textColor.withValues(alpha: 0.6),
                        ),
                        onPressed: () => _toggleFavorite(_weather!.cityName),
                      )
                    else
                      const SizedBox(width: 48), // Balancing spacer when null
                  ],
                ),

                const SizedBox(height: 4),

                // Current Date & Time Display
                Text(
                  _getFormattedDate(),
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                    color: textColor.withValues(alpha: 0.6),
                  ),
                ),

                const SizedBox(height: 16),

                // Loader or Weather Animation
                _isLoading
                    ? SizedBox(
                        height: 240,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: textColor.withValues(alpha: 0.8),
                          ),
                        ),
                      )
                    : Lottie.asset(
                        getWeatherAnimation(_weather?.mainCondition),
                        height: 240,
                      ),

                const SizedBox(height: 20),

                // Temperature
                Text(
                  _weather != null ? '${_weather!.temperature.round()}°' : '',
                  style: GoogleFonts.poppins(
                    fontSize: 88,
                    fontWeight: FontWeight.w200,
                    color: mainTemperatureColor,
                    height: 1.1,
                  ),
                ),

                const SizedBox(height: 4),

                // Condition Text
                Text(
                  _weather?.mainCondition.toUpperCase() ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 4,
                    color: textColor.withValues(alpha: 0.8),
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