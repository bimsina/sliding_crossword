import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_crossword/core/theme/state/theme_notifier.dart';

class ThemeSelectorButton extends StatelessWidget {
  const ThemeSelectorButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        IconButton(
            onPressed: () {
              showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
                  builder: (context) => const _ThemeSelectorDialog());
            },
            icon: const Icon(Icons.palette_rounded)),
      ],
    );
  }
}

class _ThemeSelectorDialog extends StatelessWidget {
  const _ThemeSelectorDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _themeState = Provider.of<ThemeNotifier>(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 40.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Select theme",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
          const SizedBox(height: 40),
          SizedBox(
            height: 100,
            child: Center(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: _themeState.availableThemes.length,
                itemBuilder: (BuildContext context, int index) {
                  final _theme = _themeState.availableThemes[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      _themeState.setTheme(_theme);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: _theme.accentColor, width: 4),
                          color: _theme.backgroundColor,
                          shape: BoxShape.circle),
                      child: _themeState.selectedTheme == _theme
                          ? Icon(
                              Icons.check,
                              color: _theme.accentColor,
                              size: 40,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
