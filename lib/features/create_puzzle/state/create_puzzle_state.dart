import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sliding_crossword/features/dialogs/utils/dialog_utils.dart';
import 'package:sliding_crossword/features/puzzle/models/puzzle/puzzle.dart';

class CreatePuzzleState extends ChangeNotifier {
  final _puzzleCollection = FirebaseFirestore.instance
      .collection('puzzles_under_review')
      .withConverter<CrosswordPuzzle>(
          fromFirestore: (snapshot, options) =>
              CrosswordPuzzle.fromJson(snapshot.data()!),
          toFirestore: (puzzle, options) => puzzle.toJson());

  final formKey = GlobalKey<FormState>();
  int _gridSize = 3;
  int get gridSize => _gridSize;
  set gridSize(int value) {
    _gridSize = value;
    _initializeControllers();
  }

  final TextEditingController _puzzleNameController = TextEditingController();
  List<TextEditingController> _promptControllers = [];
  List<TextEditingController> _answerControllers = [];

  List<TextEditingController> get promptControllers => _promptControllers;
  List<TextEditingController> get answerControllers => _answerControllers;
  TextEditingController get puzzleNameController => _puzzleNameController;
  final User _user;

  CreatePuzzleState(this._user) {
    _initializeControllers();
  }

  uploadPuzzle(BuildContext context) {
    final _promptList =
        _promptControllers.map((controller) => controller.text).toList();
    final _answersList =
        _answerControllers.map((controller) => controller.text).toList();
    final _downPrompt = _promptList.sublist(0, _gridSize);
    final _downAnswers = _answersList.sublist(0, _gridSize);
    final _acrossPrompt = _promptList.sublist(_gridSize);
    final _acrossAnswers = _answersList.sublist(_gridSize);

    if (!_checkIfValid(_acrossAnswers.join(), _downAnswers.join())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The puzzle has some problems.')),
      );
      return;
    }

    final List<Question> _acrossQuestions = _acrossPrompt
        .asMap()
        .map((index, prompt) => MapEntry(
              index,
              Question(
                prompt: prompt,
                answer: _acrossAnswers[index],
              ),
            ))
        .values
        .toList();

    final List<Question> _downQuestions = _downPrompt
        .asMap()
        .map((index, prompt) => MapEntry(
              index,
              Question(
                prompt: prompt,
                answer: _downAnswers[index],
              ),
            ))
        .values
        .toList();

    final _doc = _puzzleCollection.doc();

    final CrosswordPuzzle _puzzle = CrosswordPuzzle(
        title: _puzzleNameController.text,
        across: _acrossQuestions,
        down: _downQuestions,
        gridSize: gridSize,
        id: _doc.id,
        authorId: _user.uid,
        createdAt: DateTime.now());

    DialogUtils.showCustomLoadingDialog(context);

    _doc.set(_puzzle).then((value) {
      GoRouter.of(context).go('/');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Puzzle added successfully.')),
      );
    }).catchError((onError) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error adding puzzle.')),
      );
    });
  }

  bool _checkIfValid(String acrossAnswers, String downAnswers) {
    String _updatedDownAnswers = "";

    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        _updatedDownAnswers += (i == gridSize - 1 && j == gridSize - 1)
            ? ""
            : downAnswers[j * gridSize + i];
      }
    }

    return _updatedDownAnswers == acrossAnswers;
  }

  @override
  void dispose() {
    _disposeControllers();
    _puzzleNameController.dispose();
    super.dispose();
  }

  _disposeControllers() {
    for (final _controller in _promptControllers) {
      _controller.dispose();
    }

    for (final _controller in _answerControllers) {
      _controller.dispose();
    }
    _promptControllers = [];
  }

  _initializeControllers() {
    _promptControllers = List.generate(
      2 * _gridSize,
      (index) => TextEditingController(),
    );
    _answerControllers = List.generate(
      2 * _gridSize,
      (index) => TextEditingController(),
    );
    notifyListeners();
  }
}
