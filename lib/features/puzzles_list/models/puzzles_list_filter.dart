export 'puzzle_difficulty.dart';

import 'package:sliding_crossword/features/puzzles_list/models/puzzle_difficulty.dart';
import 'package:sliding_crossword/features/puzzles_list/models/sort_direction.dart';
import 'package:sliding_crossword/features/puzzles_list/models/sort_order.dart';

class PuzzlesListFilter {
  final PuzzleDifficulty difficulty;
  final SortOrder sortOrder;
  final SortDirection sortDirection;

  PuzzlesListFilter(
      {this.difficulty = PuzzleDifficulty.easy,
      this.sortOrder = SortOrder.date,
      this.sortDirection = SortDirection.descending});
}
