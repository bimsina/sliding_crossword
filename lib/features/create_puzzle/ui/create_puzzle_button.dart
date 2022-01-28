import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreatePuzzleButton extends StatelessWidget {
  const CreatePuzzleButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: 'create_puzzle',
      onPressed: () {
        context.push('/create-puzzle');
      },
      icon: const Icon(Icons.add),
      label: const Text("Create your puzzle"),
    );
  }
}
