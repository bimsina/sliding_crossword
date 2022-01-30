import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_crossword/core/theme/models/custom_theme.dart';

const List<CustomTheme> _availableThemes = [
  CustomTheme(
      id: 'dark_green',
      backgroundColor: Color(0xff202020),
      accentColor: Color(0xff1ed760),
      brightness: Brightness.dark,
      tileColor: Color(0xff313131)),
  CustomTheme(
      id: 'white_blue',
      backgroundColor: Color(0xfff8f9fa),
      accentColor: Color(0xff0468d7),
      brightness: Brightness.light,
      tileColor: Color(0xffffffff)),
  CustomTheme(
      id: 'play_green',
      backgroundColor: Color(0xff1e1e1e),
      accentColor: Color(0xff00a470),
      brightness: Brightness.dark,
      tileColor: Color(0xff303030)),
  CustomTheme(
      id: 'dark_blue',
      backgroundColor: Color(0xff222222),
      accentColor: Color(0xff0077d3),
      brightness: Brightness.dark,
      tileColor: Color(0xff333335)),
  CustomTheme(
      id: 'amoled_black',
      backgroundColor: Colors.black,
      accentColor: Colors.yellow,
      brightness: Brightness.dark,
      tileColor: Color(0xff3a3a3c)),
];

class ThemeNotifier extends ChangeNotifier {
  CustomTheme _selectedTheme = _availableThemes.first;
  CustomTheme get selectedTheme => _selectedTheme;

  List<CustomTheme> get availableThemes => _availableThemes;

  late SharedPreferences _preferences;

  ThemeNotifier() {
    _selectedTheme = _availableThemes.first;
    _init();
  }

  void _init() async {
    await _initPrefs();
    _fetchPersistedTheme();
  }

  Future<void> _initPrefs() async {
    _preferences = await SharedPreferences.getInstance();
  }

  _fetchPersistedTheme() {
    final _persistedThemeId =
        _preferences.getString('themeId') ?? _availableThemes.first.id;
    _selectedTheme =
        _availableThemes.firstWhere((theme) => theme.id == _persistedThemeId);
    notifyListeners();
  }

  void setTheme(CustomTheme theme) {
    _selectedTheme = theme;
    notifyListeners();
    _persistThemeSelection();
  }

  Future<void> _persistThemeSelection() async {
    _preferences.setString('themeId', _selectedTheme.id);
  }

  ThemeData get theme => ThemeData(
      brightness: _selectedTheme.brightness,
      fontFamily: "GoogleSans",
      scaffoldBackgroundColor: _selectedTheme.backgroundColor,
      cardColor: _selectedTheme.tileColor,
      cardTheme: const CardTheme(elevation: 0),
      colorScheme: _selectedTheme.brightness == Brightness.light
          ? const ColorScheme.light()
              .copyWith(secondary: _selectedTheme.accentColor)
          : const ColorScheme.dark()
              .copyWith(secondary: _selectedTheme.accentColor),
      focusColor: _selectedTheme.accentColor.withOpacity(0.1),
      hoverColor: _selectedTheme.accentColor.withOpacity(0.01),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: _selectedTheme.accentColor.withOpacity(0.11),
          foregroundColor: _selectedTheme.accentColor,
          highlightElevation: 0,
          hoverElevation: 0,
          focusElevation: 0,
          elevation: 0),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
        primary: _selectedTheme.accentColor,
      )),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
        primary: _selectedTheme.accentColor,
      )),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
        primary: _selectedTheme.accentColor,
      )),
      buttonTheme: ButtonThemeData(
          buttonColor: _selectedTheme.accentColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0))),
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
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
            borderSide: BorderSide(color: _selectedTheme.tileColor)),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: _selectedTheme.accentColor)),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: _selectedTheme.accentColor,
        selectionColor: _selectedTheme.accentColor.withOpacity(0.1),
        selectionHandleColor: _selectedTheme.accentColor,
      ),
      highlightColor: _selectedTheme.accentColor.withOpacity(0.01),
      splashColor: _selectedTheme.accentColor.withOpacity(0.1),
      snackBarTheme:
          const SnackBarThemeData(behavior: SnackBarBehavior.floating),
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
}
