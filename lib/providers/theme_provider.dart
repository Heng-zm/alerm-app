import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  // Default accent color
  Color _accentColor = const Color(0xFFFF9F0A);

  // Getter to allow widgets to read the current accent color
  Color get accentColor => _accentColor;

  // Setter to allow widgets to change the accent color
  void setAccentColor(Color newColor) {
    _accentColor = newColor;
    // This is the crucial part: it tells all listening widgets to rebuild.
    notifyListeners();
  }
}
