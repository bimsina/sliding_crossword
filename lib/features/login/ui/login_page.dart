import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_crossword/core/state/user_state.dart';
import 'package:sliding_crossword/core/theme/ui/app_logo.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _userState = Provider.of<UserState>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign In to continue"),
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const AppLogo(),
              const SizedBox(height: 50),
              _LoginButton(
                  onPressed: () {
                    _userState.signInWithGoogle(context);
                  },
                  title: "Sign in with Google",
                  isLoading: _userState.status == AuthStatus.loggingIn),
              const SizedBox(height: 20),
              _LoginButton(
                  onPressed: () {
                    _userState.signInAnonymously(context);
                  },
                  title: "Sign in Anonymously",
                  isLoading: _userState.status == AuthStatus.loggingIn),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final bool isLoading;

  const _LoginButton(
      {Key? key,
      required this.onPressed,
      required this.title,
      required this.isLoading})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: title,
      onPressed: isLoading ? null : onPressed,
      label: Text(title),
    );
  }
}
