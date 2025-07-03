import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // Predefined color options for the user to choose from
  final List<Color> _colorOptions = const [
    Color(0xFFFF9F0A), // Default Orange
    Color(0xFF0A84FF), // Blue
    Color(0xFFFF453A), // Red
    Color(0xFFBF5AF2), // Purple
    Color(0xFF32D74B), // Green
    Color(0xFFE5DE00), // Yellow
  ];

  // Shows the color picker dialog
  void _showColorPickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        // Use `Provider.of` with `listen: false` when you are only calling a method.
        final themeProvider =
            Provider.of<ThemeProvider>(context, listen: false);

        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2E),
          title: const Text('Select Accent Color',
              style: TextStyle(color: Colors.white)),
          content: Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            children: _colorOptions.map((color) {
              return GestureDetector(
                onTap: () {
                  themeProvider.setAccentColor(color);
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: CircleAvatar(
                  backgroundColor: color,
                  radius: 22,
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Here we listen to changes to display the current color
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Accent Color',
                  style: TextStyle(color: Colors.white, fontSize: 17)),
              trailing: CircleAvatar(
                backgroundColor: themeProvider.accentColor,
                radius: 14,
              ),
              onTap: () => _showColorPickerDialog(context),
            ),
          ),
        ],
      ),
    );
  }
}
