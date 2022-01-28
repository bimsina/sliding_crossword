import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sliding_crossword/core/theme/state/theme_notifier.dart';
import 'package:sliding_crossword/core/ui/responsive_builder.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _themeState = Provider.of<ThemeNotifier>(context);
    final color = _themeState.selectedTheme.accentColor;
    return ResponsiveLayoutBuilder(
        small: (_, __) => _logo(100, color),
        medium: (_, __) => _logo(150, color),
        large: (_, __) => _logo(250, color));
  }

  Widget _logo(double height, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          "assets/images/logo.svg",
          height: height,
          color: color,
        ),
        const SizedBox(height: 10),
        Wrap(
          children: [
            Text(
              "Sliding ",
              style: TextStyle(fontSize: height * 0.3, color: color),
            ),
            Text(
              "Crossword",
              style: TextStyle(
                  fontSize: height * 0.3, fontWeight: FontWeight.bold),
            ),
          ],
        )
      ],
    );
  }
}
