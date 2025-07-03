import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import 'providers/theme_provider.dart';
import 'screens/alarms_screen.dart';
import 'screens/stopwatch_screen.dart';
import 'screens/timer_screen.dart';
import 'screens/world_clock_screen.dart';
import 'services/alarm_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await AlarmService().initialize();
  await Permission.notification.request();
  if (await Permission.scheduleExactAlarm.isDenied) {
    await Permission.scheduleExactAlarm.request();
  }

  // DO NOT reschedule alarms here.
  // await AlarmService().rescheduleAlarms(); // <-- REMOVE THIS

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const ClockApp(),
    ),
  );
}

class ClockApp extends StatelessWidget {
  const ClockApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clock',
      navigatorKey: AlarmService.navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme)
            .apply(bodyColor: Colors.white, displayColor: Colors.white),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    WorldClockScreen(),
    AlarmsScreen(),
    StopwatchScreen(),
    TimerScreen(),
  ];

  // FIX #2: RESCHEDULE ALARMS IN A SAFER PLACE
  @override
  void initState() {
    super.initState();
    // This is a much more stable place to run startup logic
    // that depends on the full app environment.
    AlarmService().rescheduleAlarms();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.language), label: 'World Clock'),
          BottomNavigationBarItem(icon: Icon(Icons.alarm), label: 'Alarm'),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Stopwatch'),
          BottomNavigationBarItem(
              icon: Icon(Icons.hourglass_bottom), label: 'Timer'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: themeProvider.accentColor,
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}
