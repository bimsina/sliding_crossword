import 'package:flutter/material.dart';
import 'package:sliding_crossword/features/dialogs/ui/loading_indicator.dart';

mixin DialogUtils {
  static void showCustomLoadingDialog(BuildContext context,
      {String? loadingText}) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => WillPopScope(
            onWillPop: _willPopCallback,
            child: CustomLoadingIndicator(
              loadingText: loadingText,
            )));
  }

  static Future<bool> _willPopCallback() async {
    return false;
  }
}
