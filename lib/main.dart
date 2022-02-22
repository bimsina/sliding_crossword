import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';
import 'package:sliding_crossword/core/state/user_state.dart';
import 'package:sliding_crossword/core/theme/state/theme_notifier.dart';
import 'features/puzzles_list/state/puzzles_list_state.dart';
import 'router.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  GoRouter.setUrlPathStrategy(UrlPathStrategy.path);

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => UserState()),
    ChangeNotifierProvider(create: (_) => ThemeNotifier()),
    ChangeNotifierProvider(create: (_) => PuzzleListState()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _themeState = Provider.of<ThemeNotifier>(context);

    return MaterialApp.router(
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      scrollBehavior: MyCustomScrollBehavior(),
      debugShowCheckedModeBanner: false,
      title: 'Sliding Puzzle',
      shortcuts: {
        ...WidgetsApp.defaultShortcuts,
        const SingleActivator(LogicalKeyboardKey.select):
            const ActivateIntent(),
        const SingleActivator(LogicalKeyboardKey.gameButtonB):
            const PrioritizedIntents(orderedIntents: [DismissIntent()]),
      },
      actions: {
        ...WidgetsApp.defaultActions,
      },
      theme: _themeState.theme,
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
          value: (_themeState.theme.brightness == Brightness.dark
                  ? SystemUiOverlayStyle.light
                  : SystemUiOverlayStyle.dark)
              .copyWith(
                  systemNavigationBarColor:
                      _themeState.selectedTheme.backgroundColor),
          child: child ?? Container()),
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
