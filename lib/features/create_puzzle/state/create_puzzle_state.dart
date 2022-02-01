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
  List<TextEditingController> _tileControllers = [];

  List<TextEditingController> get promptControllers => _promptControllers;
  List<TextEditingController> get tileControllers => _tileControllers;
  TextEditingController get puzzleNameController => _puzzleNameController;
  final User _user;

  CreatePuzzleState(this._user) {
    _initializeControllers();
  }

  uploadPuzzle(BuildContext context) {
    final _promptList =
        _promptControllers.map((controller) => controller.text).toList();
    final _downPrompt = _promptList.sublist(0, _gridSize);
    final _acrossPrompt = _promptList.sublist(_gridSize);

    List<String> _acrossAnswers = [];
    List<String> _downAnswers = [];

    for (int i = 0; i < _gridSize; i++) {
      String _singleAcross = "";
      String _singleDown = "";

      for (int j = 0; j < _gridSize; j++) {
        final _acrossIndex = j + (i * _gridSize);
        final _acrossValue = _acrossIndex == _gridSize * _gridSize - 1
            ? " "
            : _tileControllers[_acrossIndex].text;
        _singleAcross += _acrossValue;

        final _downIndex = i + (j * _gridSize);
        final _downvalue = _downIndex == _gridSize * _gridSize - 1
            ? " "
            : _tileControllers[_downIndex].text;
        _singleDown += _downvalue;
      }
      _acrossAnswers.add(_singleAcross);
      _downAnswers.add(_singleDown);
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

    for (final _controller in _tileControllers) {
      _controller.dispose();
    }
    _promptControllers = [];
  }

  _initializeControllers() {
    _disposeControllers();
    _promptControllers = List.generate(
      2 * _gridSize,
      (index) => TextEditingController(),
    );
    _tileControllers = List.generate(
      gridSize * _gridSize - 1,
      (index) => TextEditingController(),
    );
    notifyListeners();
  }
}
