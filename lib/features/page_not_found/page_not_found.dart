import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sliding_crossword/core/theme/ui/app_logo.dart';

class PageNotFound extends StatelessWidget {
  const PageNotFound({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppLogo(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Page not found',
                  style: Theme.of(context).textTheme.headline4,
                ),
              ),
              FloatingActionButton.extended(
                  onPressed: () {
                    context.go('/');
                  },
                  icon: const Icon(Icons.home),
                  label: const Text("Go Home"))
            ],
          ),
        ),
      ),
    );
  }
}
