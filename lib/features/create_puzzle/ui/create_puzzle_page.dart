import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_crossword/features/create_puzzle/state/create_puzzle_state.dart';
import 'package:sliding_crossword/features/login/ui/login_page.dart';

class CreatePuzzlePage extends StatelessWidget {
  const CreatePuzzlePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoginPage();
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text("Create Puzzle"),
          ),
          body: ChangeNotifierProvider(
              create: (context) => CreatePuzzleState(context),
              child: const _CreatePuzzlePagePresenter()),
        );
      },
    );
  }
}

class _CreatePuzzlePagePresenter extends StatelessWidget {
  const _CreatePuzzlePagePresenter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [1, 2, 3]
          .map((i) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(),
              ))
          .toList(),
    );
  }
}
