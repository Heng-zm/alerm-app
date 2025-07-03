import 'package:flutter/material.dart';

class WorldClockScreen extends StatefulWidget {
  const WorldClockScreen({super.key});

  @override
  State<WorldClockScreen> createState() => _WorldClockScreenState();
}

class _WorldClockScreenState extends State<WorldClockScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('World Clock'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'World Clock Page Content',
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
