import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
      body: SizedBox(
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
                icon: FontAwesomeIcons.google,
                isLoading: _userState.status == AuthStatus.loggingIn),
            const SizedBox(height: 20),
            _LoginButton(
                onPressed: () {
                  _userState.signInAnonymously(context);
                },
                title: "Sign in with Anonymously",
                icon: Icons.person,
                isLoading: _userState.status == AuthStatus.loggingIn),
          ],
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final IconData icon;
  final bool isLoading;

  const _LoginButton(
      {Key? key,
      required this.onPressed,
      required this.title,
      required this.icon,
      required this.isLoading})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: title,
      onPressed: isLoading ? null : onPressed,
      icon: Icon(icon),
      label: Text(title),
    );
  }
}
