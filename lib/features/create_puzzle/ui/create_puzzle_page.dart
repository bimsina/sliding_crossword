import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          body: SafeArea(
            child: ChangeNotifierProvider(
                create: (context) => CreatePuzzleState(snapshot.data!),
                child: const _CreatePuzzlePagePresenter()),
          ),
        );
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
      length: 2,
      child: Form(
        key: _state.formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: <Widget>[
              // Add TextFormFields and ElevatedButton here.
              Expanded(
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
                            items: <int>[3, 4, 5, 6].map((int value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text(value.toString()),
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
                        decoration: const InputDecoration(
                            hintText: "Enter Puzzle Name"),
                        // The validator receives the text that the user has entered.
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }

                          return null;
                        },
                      ),
                    ),
                    const TabBar(tabs: [
                      Tab(text: "Down"),
                      Tab(text: "Across"),
                    ]),
                    Expanded(
                        key: Key("${_state.gridSize}"),
                        child: const TabBarView(children: [
                          _PromptAndAnswerTextFields(isAcross: false),
                          _PromptAndAnswerTextFields(isAcross: true),
                        ]))
                  ],
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
                              content:
                                  Text('Please fill up the data correctly.')),
                        );
                      }
                    },
                    icon: const Icon(Icons.done),
                    label: const Text('Submit'),
                  ),
                  FloatingActionButton.extended(
                    heroTag: 'view_puzzle',
                    onPressed: () {
                      final _answersList = _state.answerControllers
                          .map((controller) =>
                              controller.text.padRight(_state.gridSize, ' '))
                          .toList();

                      final _downAnswers =
                          _answersList.sublist(0, _state.gridSize).join();
                      final _acrossAnswers =
                          _answersList.sublist(_state.gridSize).join();
                      String _updatedDownAnswers = "";

                      for (int i = 0; i < _state.gridSize; i++) {
                        for (int j = 0; j < _state.gridSize; j++) {
                          _updatedDownAnswers +=
                              _downAnswers[j * _state.gridSize + i];
                        }
                      }

                      showModalBottomSheet(
                          backgroundColor: Colors.transparent,
                          context: context,
                          builder: (context) {
                            return _PuzzleRenderer(
                              downWords: _updatedDownAnswers,
                              acrossWords: _acrossAnswers,
                              gridSize: _state.gridSize,
                            );
                          });
                    },
                    icon: const Icon(Icons.grid_3x3),
                    label: const Text('Show puzzle'),
                  ),
                ],
              ),
            ],
          ),
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
                            "${(isAcross ? item - _state.gridSize : item) + 1} ${isAcross ? "Across" : "Down"} "),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _state.promptControllers[item],
                              decoration: const InputDecoration(
                                  hintText: "Enter prompt"),
                              // The validator receives the text that the user has entered.
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _state.answerControllers[item],
                              decoration:
                                  const InputDecoration(hintText: "Answer"),
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(
                                    (item == _state.gridSize - 1 ||
                                            item == _state.gridSize * 2 - 1)
                                        ? _state.gridSize - 1
                                        : _state.gridSize)
                              ],
                              // The validator receives the text that the user has entered.
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter some text';
                                }

                                final bool _isLastAns =
                                    (item == _state.gridSize - 1 ||
                                        item == _state.gridSize * 2 - 1);
                                if (_isLastAns &&
                                    value.length == _state.gridSize - 1) {
                                  return null;
                                }
                                if (value.length != _state.gridSize) {
                                  return 'Please enter ${_state.gridSize} characters';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
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

class _PuzzleRenderer extends StatelessWidget {
  final String acrossWords;
  final String downWords;
  final int gridSize;
  const _PuzzleRenderer(
      {Key? key,
      required this.acrossWords,
      required this.downWords,
      required this.gridSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: AspectRatio(
            aspectRatio: 1,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridSize,
              ),
              itemCount: gridSize * gridSize,
              itemBuilder: (BuildContext context, int index) {
                if (index == gridSize * gridSize - 1) {
                  return Container();
                }
                final String _text = acrossWords[index] != " "
                    ? acrossWords[index]
                    : downWords[index];
                return Card(
                  color: Theme.of(context).colorScheme.secondary,
                  child: Center(
                    child: AutoSizeText(
                      _text.toUpperCase(),
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).scaffoldBackgroundColor),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
