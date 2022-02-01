export 'puzzle_difficulty.dart';

import 'package:equatable/equatable.dart';
import 'package:sliding_crossword/features/puzzles_list/models/puzzle_difficulty.dart';
import 'package:sliding_crossword/features/puzzles_list/models/sort_direction.dart';
import 'package:sliding_crossword/features/puzzles_list/models/sort_order.dart';

class PuzzlesListFilter extends Equatable {
  final PuzzleDifficulty difficulty;
  final SortOrder sortOrder;
  final SortDirection sortDirection;

  const PuzzlesListFilter(
      {this.difficulty = PuzzleDifficulty.easy,
      this.sortOrder = SortOrder.date,
      this.sortDirection = SortDirection.descending});

  PuzzlesListFilter copyWith(
      {PuzzleDifficulty? difficulty,
      SortOrder? sortOrder,
      SortDirection? sortDirection}) {
    return PuzzlesListFilter(
        difficulty: difficulty ?? this.difficulty,
        sortOrder: sortOrder ?? this.sortOrder,
        sortDirection: sortDirection ?? this.sortDirection);
  }

  @override
  String toString() {
    return '${difficulty.index}-${sortOrder.index}-${sortDirection.index}';
  }

  @override
  List<Object?> get props =>
      [difficulty.index, sortOrder.index, sortDirection.index];
}
