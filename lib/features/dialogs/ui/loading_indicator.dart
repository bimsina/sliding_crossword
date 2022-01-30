import 'package:flutter/material.dart';

class CustomLoadingIndicator extends StatelessWidget {
  final String? loadingText;

  const CustomLoadingIndicator({Key? key, this.loadingText}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 15,
            height: 15,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.secondary),
            ),
          ),
          if (loadingText != null)
            Container(
              constraints: const BoxConstraints(maxWidth: 300),
              padding: const EdgeInsets.all(8.0),
              child: Text(
                loadingText!,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary),
              ),
            )
        ],
      ),
    );
  }
}
