import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sliding_crossword/core/theme/models/custom_theme.dart';

const List<CustomTheme> _availableThemes = [
  CustomTheme(
      id: 'default_dark',
      backgroundColor: Color(0xff121213),
      accentColor: Color(0xffb59f37),
      brightness: Brightness.dark,
      tileColor: Color(0xff3a3a3c)),
  CustomTheme(
      id: 'amoled_black',
      backgroundColor: Colors.black,
      accentColor: Colors.yellow,
      brightness: Brightness.dark,
      tileColor: Color(0xff3a3a3c)),
  CustomTheme(
      id: 'default_white',
      backgroundColor: Color(0xfff8f9fa),
      accentColor: Color(0xff4285f4),
      brightness: Brightness.light,
      tileColor: Color(0xffffffff)),
];

class ThemeNotifier extends ChangeNotifier {
  CustomTheme _selectedTheme = _availableThemes.first;
  CustomTheme get selectedTheme => _selectedTheme;

  List<CustomTheme> get availableThemes => _availableThemes;

  ThemeData get theme => ThemeData(
      brightness: _selectedTheme.brightness,
      fontFamily: GoogleFonts.openSans().fontFamily,
      scaffoldBackgroundColor: _selectedTheme.backgroundColor,
      cardColor: _selectedTheme.tileColor,
      colorScheme: _selectedTheme.brightness == Brightness.light
          ? const ColorScheme.light()
              .copyWith(secondary: _selectedTheme.accentColor)
          : const ColorScheme.dark()
              .copyWith(secondary: _selectedTheme.accentColor),
      focusColor: _selectedTheme.accentColor,
      hoverColor: _selectedTheme.accentColor.withOpacity(0.2),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      tabBarTheme: TabBarTheme(
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            width: 2.0,
            color: _selectedTheme.accentColor,
          ),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: _selectedTheme.brightness == Brightness.light
            ? Colors.black
            : Colors.white,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: _selectedTheme.backgroundColor,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _selectedTheme.brightness == Brightness.light
              ? Colors.black
              : Colors.white,
        ),
        iconTheme: IconThemeData(
            color: _selectedTheme.brightness == Brightness.light
                ? Colors.black
                : Colors.white),
      ));

  ThemeNotifier() {
    _selectedTheme = _availableThemes.first;
  }

  void setTheme(CustomTheme theme) {
    _selectedTheme = theme;
    notifyListeners();
  }
}
