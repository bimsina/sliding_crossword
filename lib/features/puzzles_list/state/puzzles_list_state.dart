import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sliding_crossword/core/enums/data_fetch_state.dart';
import 'package:sliding_crossword/features/puzzle/models/puzzle/puzzle.dart';
import 'package:sliding_crossword/features/puzzles_list/models/puzzles_list_filter.dart';
import 'package:sliding_crossword/features/puzzles_list/models/sort_direction.dart';
import 'package:sliding_crossword/features/puzzles_list/models/sort_order.dart';

class PuzzleListState extends ChangeNotifier {
  final List<CrosswordPuzzle> _puzzles = [];
  List<CrosswordPuzzle> get puzzlesList => _puzzles;

  DataFetchState _state = DataFetchState.loading;
  DataFetchState get state => _state;
  set state(DataFetchState newState) {
    _state = newState;
    notifyListeners();
  }

  PuzzlesListFilter? _filter;
  PuzzlesListFilter? get filter => _filter;
  set filter(PuzzlesListFilter? newFilter) {
    if (newFilter != _filter) {
      _filter = newFilter;
      fetchPuzzles();
    }
  }

  final Map<String, List<CrosswordPuzzle>> _puzzlesCache = {};

  fetchPuzzles({bool clearPuzzles = true}) {
    if (_filter == null) return;
    state = DataFetchState.loading;
    if (clearPuzzles) {
      _puzzles.clear();
    }

    if (_puzzlesCache.keys.contains(_filter.toString())) {
      _puzzles.clear();
      _puzzles.addAll(_puzzlesCache[_filter.toString()] ?? []);
      state = DataFetchState.loaded;
      return;
    }

    final _puzzlesCollection = FirebaseFirestore.instance
        .collection('puzzles_under_review')
        .where("grid_size", isEqualTo: _filter!.difficulty.index + 3)
        .orderBy(
            _filter!.sortOrder == SortOrder.date
                ? 'created_at'
                : 'times_played',
            descending: _filter!.sortDirection == SortDirection.descending)
        .withConverter<CrosswordPuzzle>(
            fromFirestore: (snapshot, options) =>
                CrosswordPuzzle.fromJson(snapshot.data()!),
            toFirestore: (puzzle, options) => puzzle.toJson());

    _puzzlesCollection.get().then((QuerySnapshot snapshot) {
      _puzzles.addAll(snapshot.docs.map((DocumentSnapshot doc) {
        return doc.data() as CrosswordPuzzle;
      }).toList());

      _puzzlesCache[_filter.toString()] = [..._puzzles];

      state = DataFetchState.loaded;
    }).catchError((error) {
      state = DataFetchState.error;
    });
    notifyListeners();
  }
}
