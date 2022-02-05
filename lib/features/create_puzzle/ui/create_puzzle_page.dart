import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sliding_crossword/features/create_puzzle/state/create_puzzle_state.dart';
import 'package:sliding_crossword/features/login/ui/login_page.dart';
import 'package:sliding_crossword/features/puzzles_list/ui/puzzles_list_page.dart';

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
        return ChangeNotifierProvider(
            create: (context) => CreatePuzzleState(snapshot.data!),
            child: const _CreatePuzzlePagePresenter());
      },
    );
  }
}

class _CreatePuzzlePagePresenter extends StatelessWidget {
  const _CreatePuzzlePagePresenter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _state = Provider.of<CreatePuzzleState>(context);
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Create Puzzle"),
          bottom: const TabBar(tabs: [
            Tab(text: "Info"),
            Tab(text: "Down"),
            Tab(text: "Across"),
            Tab(text: "Puzzle"),
          ]),
        ),
        body: SafeArea(
          child: Form(
            key: _state.formKey,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: <Widget>[
                  Expanded(
                    key: Key("${_state.gridSize}"),
                    child: const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: TabBarView(
                        physics: BouncingScrollPhysics(),
                        children: [
                          _PuzzleInfo(),
                          _PromptAndAnswerTextFields(isAcross: false),
                          _PromptAndAnswerTextFields(isAcross: true),
                          _PuzzleTextFields(),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      FloatingActionButton.extended(
                        heroTag: 'submit_button',
                        onPressed: () {
                          if (_state.formKey.currentState!.validate()) {
                            _state.uploadPuzzle(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Please fill up the data correctly.')),
                            );
                          }
                        },
                        icon: const Icon(Icons.done),
                        label: const Text('Submit'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PuzzleInfo extends StatelessWidget {
  const _PuzzleInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _state = Provider.of<CreatePuzzleState>(context);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Card(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Grid Size : "),
                DropdownButton<int>(
                  underline: Container(),
                  value: _state.gridSize,
                  items: PuzzleDifficulty.values.map((PuzzleDifficulty value) {
                    return DropdownMenuItem<int>(
                      value: value.index + 3,
                      child: Text(
                          "${value.index + 3}x${value.index + 3} : ${value.name}",
                          textAlign: TextAlign.center),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      _state.gridSize = val;
                    }
                  },
                ),
              ],
            ),
          ),
          Card(
            child: TextFormField(
              controller: _state.puzzleNameController,
              decoration: const InputDecoration(hintText: "Enter Puzzle Name"),
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }

                return null;
              },
            ),
          ),
          Card(
            child: TextFormField(
              controller: _state.maxSecondsController,
              decoration:
                  const InputDecoration(hintText: "Max Seconds (optional)"),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp("[0-9]")),
              ],
            ),
          ),
          Card(
            child: TextFormField(
              controller: _state.maxMovesController,
              decoration:
                  const InputDecoration(hintText: "Max Moves (optional)"),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp("[0-9]")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PuzzleTextFields extends StatelessWidget {
  const _PuzzleTextFields({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _state = Provider.of<CreatePuzzleState>(context);
    return Center(
      child: Container(
        margin: const EdgeInsets.all(8.0),
        constraints: const BoxConstraints(maxWidth: 600),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _state.gridSize,
          ),
          itemCount: _state.gridSize * _state.gridSize - 1,
          itemBuilder: (BuildContext context, int index) {
            return Card(
                child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _state.tileControllers[index],
                  decoration: const InputDecoration(
                    hintText: "Answer",
                  ),
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(1),
                    FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z]")),
                  ],
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }

                    return null;
                  },
                ),
              ),
            ));
          },
        ),
      ),
    );
  }
}

class _PromptAndAnswerTextFields extends StatelessWidget {
  final bool isAcross;
  const _PromptAndAnswerTextFields({required this.isAcross, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _state = Provider.of<CreatePuzzleState>(context);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: List.generate(_state.gridSize,
                (index) => isAcross ? index + _state.gridSize : index)
            .map(
              (item) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          "${(isAcross ? item - _state.gridSize : item) + 1} ${isAcross ? "Across" : "Down"}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: _state.promptControllers[item],
                        decoration:
                            const InputDecoration(hintText: "Enter prompt"),
                        // The validator receives the text that the user has entered.
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
