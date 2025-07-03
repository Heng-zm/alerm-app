import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with SingleTickerProviderStateMixin {
  int _selectedHours = 0;
  int _selectedMinutes = 0;
  int _selectedSeconds = 0;
  // FIX: Marked as final
  final String _timerLabel = 'Timer';
  final String _selectedSound = 'Radial';

  bool _isTimerRunning = false;
  bool _isTimerPaused = false;
  late AnimationController _animationController;
  late Duration _totalDuration;
  late DateTime _endTime;

  static const Color _greenColor = Color(0xFF34C759);
  static const Color _redColor = Color(0xFFFF453A);
  static const Color _activeGreyColor = Color(0xFF333333);
  static const Color _orangeColor = Color(0xFFFF9F0A);

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _totalDuration = Duration(
      hours: _selectedHours,
      minutes: _selectedMinutes,
      seconds: _selectedSeconds,
    );
    if (_totalDuration.inSeconds > 0) {
      setState(() {
        _isTimerRunning = true;
        _endTime = DateTime.now().add(_totalDuration);
        _animationController.duration = _totalDuration;
        _animationController.reverse(from: 1.0);
      });
    }
  }

  void _pauseResumeTimer() {
    setState(() {
      if (_isTimerPaused) {
        _isTimerPaused = false;
        final remainingTime = _endTime.difference(DateTime.now());
        _animationController.duration = remainingTime;
        _animationController.reverse(from: 1.0);
      } else {
        _isTimerPaused = true;
        _animationController.stop();
      }
    });
  }

  void _cancelTimer() {
    setState(() {
      _isTimerRunning = false;
      _isTimerPaused = false;
      _animationController.stop();
      _animationController.value = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Timers', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isTimerRunning ? _buildRunningUI() : _buildSetupUI(),
          ),
        ),
      ),
    );
  }

  Widget _buildRunningUI() {
    Duration remainingDuration =
        _animationController.duration! * _animationController.value;
    String remainingTime = _formatCountdown(remainingDuration);

    return Column(
      key: const ValueKey('RunningUI'),
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        SizedBox(
          width: 300,
          height: 300,
          child: CustomPaint(
            painter: TimerPainter(
              progress: _animationController.value,
              progressColor: _orangeColor,
              backgroundColor: _activeGreyColor,
            ),
            child: Center(
              child: Text(
                remainingTime,
                style: const TextStyle(
                    fontSize: 64,
                    color: Colors.white,
                    fontWeight: FontWeight.w200),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications, color: _orangeColor),
            const SizedBox(width: 8),
            Text(
              '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildButton(
                text: _isTimerPaused ? 'Resume' : 'Pause',
                color: _activeGreyColor,
                onPressed: _pauseResumeTimer),
            _buildButton(
                text: 'Cancel', color: _redColor, onPressed: _cancelTimer),
          ],
        ),
      ],
    );
  }

  Widget _buildSetupUI() {
    return Column(
      key: const ValueKey('SetupUI'),
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildTimePicker(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildButton(
                text: 'Lap', color: const Color(0xFF1C1C1E), onPressed: null),
            _buildButton(
                text: 'Start', color: _greenColor, onPressed: _startTimer),
          ],
        ),
        _buildTimerOptions(),
      ],
    );
  }

  String _formatCountdown(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0
        ? '$hours:$minutes:$seconds'
        : '$minutes:$seconds';
  }

  Widget _buildTimePicker() {
    return SizedBox(
      height: 250,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPickerColumn(
              24, 'Hours', (value) => _selectedHours = value, _selectedHours),
          _buildPickerColumn(
              60, 'Min', (value) => _selectedMinutes = value, _selectedMinutes),
          _buildPickerColumn(
              60, 'Sec', (value) => _selectedSeconds = value, _selectedSeconds),
        ],
      ),
    );
  }

  Widget _buildPickerColumn(
      int max, String label, ValueChanged<int> onChanged, int initialItem) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 200,
            child: CupertinoPicker(
              scrollController:
                  FixedExtentScrollController(initialItem: initialItem),
              itemExtent: 50.0,
              looping: true,
              onSelectedItemChanged: onChanged,
              children: List<Widget>.generate(max, (index) {
                return Center(
                    child: Text(index.toString(),
                        style: const TextStyle(
                            fontSize: 32, color: Colors.white)));
              }),
            ),
          ),
          Text(label,
              style: const TextStyle(fontSize: 16, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildTimerOptions() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _buildSettingsRow('Label', _timerLabel, () {}),
          Divider(color: Colors.grey[850], height: 1, indent: 16),
          _buildSettingsRow('When Timer Ends', _selectedSound, () {}),
        ],
      ),
    );
  }

  Widget _buildButton(
      {required String text,
      required Color color,
      required VoidCallback? onPressed}) {
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

  Widget _buildSettingsRow(String title, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 17, color: Colors.white)),
            Row(
              children: [
                Text(value,
                    style: TextStyle(fontSize: 17, color: Colors.grey[400])),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios,
                    color: Colors.grey[600], size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TimerPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;

  TimerPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 10.0;
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, backgroundPaint);
    final sweepAngle = progress * -2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant TimerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
