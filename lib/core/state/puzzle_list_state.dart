import 'package:flutter/material.dart';
import 'package:sliding_crossword/puzzle/models/puzzle/puzzle.dart';

class PuzzleListState extends ChangeNotifier {
  late List<CrosswordPuzzle> _puzzles;

  List<CrosswordPuzzle> get puzzles => _puzzles;
  PuzzleListState() {
    _puzzles = [
      CrosswordPuzzle(title: "Sample Puzzle", gridSize: 4, across: [
        Question(prompt: "Opposite of leave.", answer: "stay"),
        Question(prompt: "Change color.", answer: "tone"),
        Question(prompt: "Not commerce.", answer: "arts"),
        Question(prompt: "Like fly.", answer: "bee"),
      ], down: [
        Question(prompt: "Plunge knife.", answer: "stab"),
        Question(prompt: "Andy __ his paper.", answer: "tore"),
        Question(prompt: "Ant.", answer: "ante"),
        Question(prompt: "No.", answer: "yes"),
      ])
    ];
  }
}
