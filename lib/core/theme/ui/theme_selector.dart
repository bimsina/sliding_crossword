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
                  backgroundColor: Colors.transparent,
                  context: context,
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
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      decoration: BoxDecoration(
        color: _themeState.selectedTheme.backgroundColor,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Select theme",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 40),
          Container(
            height: 100,
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: _themeState.availableThemes.length,
                itemBuilder: (BuildContext context, int index) {
                  final _theme = _themeState.availableThemes[index];
                  return Card(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8.0),
                      onTap: () {
                        _themeState.setTheme(_theme);
                      },
                      child: Container(
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
                                Icons.check_circle,
                                color: _theme.accentColor,
                                size: 40,
                              )
                            : null,
                      ),
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
