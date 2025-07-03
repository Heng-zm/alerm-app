import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Enum to manage the stopwatch states for clearer logic
enum StopwatchState { stopped, running, paused }

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  String _formattedTime = '00:00.00';
  final List<String> _laps = [];
  StopwatchState _currentState = StopwatchState.stopped;

  // Colors for buttons based on the UI concept
  static const Color _greenColor = Color(0xFF34C759);
  static const Color _redColor = Color(0xFFFF453A);
  static const Color _activeGreyColor = Color(0xFF333333);
  static const Color _disabledGreyColor = Color(0xFF1C1C1E);

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Formats duration into MM:SS.ms
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    String twoDigitMilliseconds =
        twoDigits(duration.inMilliseconds.remainder(1000) ~/ 10);
    return '$twoDigitMinutes:$twoDigitSeconds.$twoDigitMilliseconds';
  }

  void _updateTime(Timer timer) {
    if (_stopwatch.isRunning) {
      setState(() {
        _formattedTime = _formatDuration(_stopwatch.elapsed);
      });
    }
  }

  void _handleStartStop() {
    if (_currentState == StopwatchState.running) {
      // --- Stop the stopwatch ---
      setState(() {
        _currentState = StopwatchState.paused;
      });
      _stopwatch.stop();
      _timer?.cancel();
    } else {
      // --- Start the stopwatch (from paused or stopped state) ---
      setState(() {
        _currentState = StopwatchState.running;
      });
      _stopwatch.start();
      _timer = Timer.periodic(const Duration(milliseconds: 30), _updateTime);
    }
  }

  void _handleLapReset() {
    if (_currentState == StopwatchState.running) {
      // --- Record a lap ---
      setState(() {
        final lapTime = _formatDuration(_stopwatch.elapsed);
        _laps.insert(0, 'Lap ${_laps.length + 1} \t\t $lapTime');
      });
    } else if (_currentState == StopwatchState.paused) {
      // --- Reset the stopwatch ---
      setState(() {
        _currentState = StopwatchState.stopped;
        _stopwatch.reset();
        _formattedTime = '00:00.00';
        _laps.clear();
      });
    }
  }

  // A helper to build styled, circular buttons
  Widget _buildButton({
    required String text,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 80,
      height: 80,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
        ),
        child: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stopwatch'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              // Main time display
              SizedBox(
                height: 250,
                child: Center(
                  child: Text(
                    _formattedTime,
                    style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.w200,
                      // Use a monospaced font for the numbers
                      fontFamily: GoogleFonts.robotoMono().fontFamily,
                    ),
                  ),
                ),
              ),
              // Buttons Row
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _buildButtons(),
                ),
              ),
              // Divider
              Divider(color: Colors.grey[800]),
              // Laps List
              Expanded(
                child: ListView.separated(
                  itemCount: _laps.length,
                  separatorBuilder: (context, index) => Divider(
                      color: Colors.grey[800], indent: 16, endIndent: 16),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _laps[index].split('\t\t')[0], // Lap number
                            style: const TextStyle(fontSize: 18),
                          ),
                          Text(
                            _laps[index].split('\t\t')[1], // Lap time
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: GoogleFonts.robotoMono().fontFamily,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Logic to determine which buttons to show based on the current state
  List<Widget> _buildButtons() {
    switch (_currentState) {
      case StopwatchState.running:
        return [
          _buildButton(
              text: 'Lap', color: _activeGreyColor, onPressed: _handleLapReset),
          _buildButton(
              text: 'Stop', color: _redColor, onPressed: _handleStartStop),
        ];
      case StopwatchState.paused:
        return [
          _buildButton(
              text: 'Reset',
              color: _activeGreyColor,
              onPressed: _handleLapReset),
          _buildButton(
              text: 'Start', color: _greenColor, onPressed: _handleStartStop),
        ];
      case StopwatchState.stopped:
      default:
        return [
          _buildButton(
              text: 'Lap',
              color: _disabledGreyColor,
              onPressed: null), // Disabled
          _buildButton(
              text: 'Start', color: _greenColor, onPressed: _handleStartStop),
        ];
    }
  }
}
