import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_crossword/core/theme/state/theme_notifier.dart';

class ThemeSelectorButton extends StatefulWidget {
  const ThemeSelectorButton({Key? key}) : super(key: key);

  @override
  State<ThemeSelectorButton> createState() => _ThemeSelectorButtonState();
}

class _ThemeSelectorButtonState extends State<ThemeSelectorButton> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final _themeNotifier = Provider.of<ThemeNotifier>(context);
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.bounceInOut,
          padding: const EdgeInsets.only(right: 40, left: 8, top: 8, bottom: 8),
          width: _isExpanded ? min(MediaQuery.of(context).size.width, 500) : 0,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: _themeNotifier.selectedTheme.tileColor,
          ),
          child: !_isExpanded
              ? const SizedBox.shrink()
              : Center(
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _themeNotifier.availableThemes.length,
                    itemBuilder: (BuildContext context, int index) {
                      final theme = _themeNotifier.availableThemes[index];
                      return InkWell(
                        onTap: () {
                          _themeNotifier.setTheme(theme);
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: theme.accentColor, width: 4),
                              color: theme.backgroundColor,
                              shape: BoxShape.circle),
                          child: _themeNotifier.selectedTheme == theme
                              ? Icon(
                                  Icons.check,
                                  color: theme.accentColor,
                                  size: 24,
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
        ),
        IconButton(
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            icon: Icon(_isExpanded ? Icons.close : Icons.palette_rounded)),
      ],
    );
  }
}

class _ThemeSelectorDialog extends StatelessWidget {
  const _ThemeSelectorDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _themeState = Provider.of<ThemeNotifier>(context);
    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: 800, minWidth: 300),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: _themeState.selectedTheme.tileColor,
        ),
        child: Wrap(
          children: _themeState.availableThemes
              .map((theme) => InkResponse(
                    splashColor: theme.accentColor,
                    onTap: () {
                      _themeState.setTheme(theme);
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: theme.accentColor, width: 4),
                          color: theme.backgroundColor,
                          shape: BoxShape.circle),
                      child: _themeState.selectedTheme == theme
                          ? Icon(
                              Icons.check,
                              color: theme.accentColor,
                              size: 24,
                            )
                          : null,
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
