import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _useAmoledDark = false;
  
  ThemeProvider() {
    _loadSettings();
  }
  
  ThemeMode get themeMode => _themeMode;
  bool get useAmoledDark => _useAmoledDark;
  
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveSettings();
    notifyListeners();
  }
  
  void toggleAmoledDark() {
    _useAmoledDark = !_useAmoledDark;
    _saveSettings();
    notifyListeners();
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt('themeMode') ?? 0;
    _themeMode = ThemeMode.values[themeModeIndex];
    _useAmoledDark = prefs.getBool('useAmoledDark') ?? false;
    notifyListeners();
  }
  
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', _themeMode.index);
    await prefs.setBool('useAmoledDark', _useAmoledDark);
  }
  
  ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.teal,
      colorScheme: ColorScheme.light(
        primary: Colors.teal,
        secondary: Colors.tealAccent,
        surface: Colors.white,
        background: Colors.grey[100]!,
      ),
      scaffoldBackgroundColor: Colors.grey[100],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black87),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[200],
        hintStyle: TextStyle(color: Colors.grey[600]),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      fontFamily: 'Cairo',
    );
  }
  
  ThemeData get darkTheme {
    final backgroundColor = _useAmoledDark ? Colors.black : Colors.grey[900];
    final surfaceColor = _useAmoledDark ? Colors.black : Colors.grey[850];
    
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.tealAccent,
      colorScheme: ColorScheme.dark(
        primary: Colors.tealAccent,
        secondary: Colors.teal,
        surface: surfaceColor!,
        background: backgroundColor!,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white70),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: _useAmoledDark ? Colors.grey[900] : Colors.grey[800],
        hintStyle: TextStyle(color: Colors.grey[400]),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.tealAccent,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      fontFamily: 'Cairo',
    );
  }
}
