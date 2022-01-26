import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:sliding_crossword/core/state/puzzle_list_state.dart';
import 'package:sliding_crossword/core/theme/state/theme_notifier.dart';
import 'package:sliding_crossword/menu/ui/menu_page.dart';

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => PuzzleListState()),
    ChangeNotifierProvider(create: (_) => ThemeNotifier())
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _themeState = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      scrollBehavior: MyCustomScrollBehavior(),
      debugShowCheckedModeBanner: false,
      title: 'Sliding Puzzle',
      theme: _themeState.theme,
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
          value: (_themeState.theme.brightness == Brightness.dark
                  ? SystemUiOverlayStyle.light
                  : SystemUiOverlayStyle.dark)
              .copyWith(
                  systemNavigationBarColor:
                      _themeState.selectedTheme.backgroundColor),
          child: child ?? Container()),
      home: const MenuPage(),
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
