import 'package:flutter/material.dart';
import '../core/constants/utils/theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  String _themeType = AppTheme.themeFriend;

  String get themeType => _themeType;

  ThemeData get currentTheme => AppTheme.getTheme(_themeType);

  bool get isLoveTheme => _themeType == AppTheme.themeLove;

  void setTheme(String themeType) {
    _themeType = themeType;
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeType == AppTheme.themeFriend) {
      _themeType = AppTheme.themeLove;
    } else {
      _themeType = AppTheme.themeFriend;
    }
    notifyListeners();
  }
}
