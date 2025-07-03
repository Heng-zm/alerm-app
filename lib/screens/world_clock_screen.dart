import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

import '../providers/theme_provider.dart';

// --- IMPORTANT: PASTE YOUR API KEY HERE ---
const String _openWeatherApiKey = 'eedede139f5c2da367b9a5694a3a978f';

class WorldClockInfo {
  final String timezone;
  final String cityName;
  final tz.Location location;
  final double lat;
  final double lon;
  String? weatherDescription;
  String? weatherIconCode;
  double? temperature;

  WorldClockInfo({
    required this.timezone,
    required this.cityName,
    required this.location,
    required this.lat,
    required this.lon,
  });
}

class WorldClockScreen extends StatefulWidget {
  const WorldClockScreen({super.key});

  @override
  State<WorldClockScreen> createState() => _WorldClockScreenState();
}

class _WorldClockScreenState extends State<WorldClockScreen> {
  Timer? _timer;
  bool _isLoading = true;
  final List<WorldClockInfo> _clocks = [];
  String? _localTimezoneString;
  tz.Location? _localLocation;

  final List<Map<String, dynamic>> _citiesData = [
    {'city': 'Tehran', 'tz': 'Asia/Tehran', 'lat': 35.6892, 'lon': 51.3890},
    {
      'city': 'New York',
      'tz': 'America/New_York',
      'lat': 40.7128,
      'lon': -74.0060
    },
    {'city': 'London', 'tz': 'Europe/London', 'lat': 51.5074, 'lon': -0.1278},
    {'city': 'Tokyo', 'tz': 'Asia/Tokyo', 'lat': 35.6895, 'lon': 139.6917},
    {
      'city': 'Sydney',
      'tz': 'Australia/Sydney',
      'lat': -33.8688,
      'lon': 151.2093
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeClocks();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initializeClocks() async {
    try {
      _localTimezoneString = await FlutterNativeTimezone.getLocalTimezone();
      _localLocation = tz.getLocation(_localTimezoneString!);

      var localCityData = _citiesData.firstWhere(
        (city) => city['tz'] == _localTimezoneString,
        orElse: () => {},
      );

      if (localCityData.isNotEmpty) {
        final localClock = WorldClockInfo(
          timezone: localCityData['tz'],
          cityName: localCityData['city'],
          location: _localLocation!,
          lat: localCityData['lat'],
          lon: localCityData['lon'],
        );
        _clocks.add(localClock);
        _fetchWeatherForClock(localClock);
      }

      for (var cityData in _citiesData) {
        if (cityData['tz'] != _localTimezoneString) {
          final clock = WorldClockInfo(
            timezone: cityData['tz'],
            cityName: cityData['city'],
            location: tz.getLocation(cityData['tz']),
            lat: cityData['lat'],
            lon: cityData['lon'],
          );
          _clocks.add(clock);
          _fetchWeatherForClock(clock);
        }
      }
    } catch (e) {
      debugPrint("Error initializing clocks: $e");
    }

    setState(() => _isLoading = false);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _fetchWeatherForClock(WorldClockInfo clock) async {
    if (_openWeatherApiKey == 'YOUR_API_KEY_HERE') return;
    try {
      final url = Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=${clock.lat}&lon=${clock.lon}&appid=$_openWeatherApiKey&units=metric');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            clock.weatherDescription = data['weather'][0]['main'];
            clock.weatherIconCode = data['weather'][0]['icon'];
            clock.temperature = data['main']['temp'];
          });
        }
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      debugPrint("Error fetching weather for ${clock.cityName}: $e");
    }
  }

  String _getOffsetString(tz.Location location) {
    if (_localLocation == null) return '';
    final now = tz.TZDateTime.now(location);
    final localNow = tz.TZDateTime.now(_localLocation!);

    if (location.name == _localLocation!.name) return now.timeZoneName;

    // FIX: Get the offset from the TZDateTime objects, not the Location objects.
    final diff = now.timeZoneOffset - localNow.timeZoneOffset;
    final hours = diff.inHours;
    final sign = hours >= 0 ? '+' : '';

    final dayDiff = now.day - localNow.day;
    String dayString = "Today,";
    if (dayDiff == 1 || (dayDiff < 0 && now.hour > localNow.hour)) {
      dayString = "Tomorrow,";
    } else if (dayDiff == -1 || (dayDiff > 0 && now.hour < localNow.hour)) {
      dayString = "Yesterday,";
    }
    return '$dayString $sign$hours HRS';
  }

  IconData _getWeatherIcon(String? iconCode) {
    if (iconCode == null) return Icons.cloud_off;
    switch (iconCode) {
      case '01d':
        return Icons.wb_sunny;
      case '01n':
        return Icons.nightlight_round;
      case '02d':
      case '02n':
      case '03d':
      case '03n':
      case '04d':
      case '04n':
        return Icons.cloud;
      case '09d':
      case '09n':
        return Icons.shower;
      case '10d':
      case '10n':
        return Icons.grain;
      case '11d':
      case '11n':
        return Icons.flash_on;
      case '13d':
      case '13n':
        return Icons.ac_unit;
      case '50d':
      case '50n':
        return Icons.waves;
      // FIX: Added a default case to ensure a value is always returned.
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () {},
          child: Text('Edit',
              style: TextStyle(color: themeProvider.accentColor, fontSize: 16)),
        ),
        title: const Text('World Clock',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: themeProvider.accentColor, size: 30),
            onPressed: () {},
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      final themeProvider = Provider.of<ThemeProvider>(context);
      return Center(
          child: CircularProgressIndicator(color: themeProvider.accentColor));
    }
    if (_clocks.isEmpty) {
      return const Center(
        child: Text('No clocks to display.',
            style: TextStyle(color: Colors.grey, fontSize: 18)),
      );
    }
    return ListView.separated(
      itemCount: _clocks.length,
      separatorBuilder: (context, index) =>
          Divider(color: Colors.grey[850], indent: 16),
      itemBuilder: (context, index) {
        final clockInfo = _clocks[index];
        final nowInTimezone = tz.TZDateTime.now(clockInfo.location);
        final bool isLocal = clockInfo.timezone == _localTimezoneString;
        return _buildClockListItem(clockInfo, nowInTimezone, isLocal: isLocal);
      },
    );
  }

  Widget _buildClockListItem(WorldClockInfo clockInfo, tz.TZDateTime now,
      {required bool isLocal}) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (clockInfo.temperature != null &&
              clockInfo.weatherIconCode != null)
            Row(
              children: [
                Icon(_getWeatherIcon(clockInfo.weatherIconCode),
                    color: Colors.grey[400], size: 16),
                const SizedBox(width: 4),
                Text('${clockInfo.temperature!.round()}°',
                    style: TextStyle(color: Colors.grey[400], fontSize: 15)),
                const SizedBox(width: 8),
                Text('•', style: TextStyle(color: Colors.grey[600])),
                const SizedBox(width: 8),
              ],
            )
          else if (_openWeatherApiKey != 'YOUR_API_KEY_HERE')
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2.0)),
            ),
          Text(_getOffsetString(clockInfo.location),
              style: TextStyle(color: Colors.grey[600], fontSize: 15)),
        ],
      ),
      subtitle: Row(
        children: [
          if (isLocal)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(Icons.location_on,
                  color: themeProvider.accentColor, size: 24),
            ),
          Flexible(
            child: Text(
              clockInfo.cityName,
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(DateFormat('h:mm').format(now),
              style:
                  const TextStyle(fontSize: 42, fontWeight: FontWeight.w200)),
          const SizedBox(width: 4),
          Text(DateFormat('a').format(now),
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w200)),
        ],
      ),
    );
  }
}
