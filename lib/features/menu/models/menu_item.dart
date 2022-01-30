import 'package:equatable/equatable.dart';
import 'package:sliding_crossword/features/puzzles_list/ui/puzzles_list_page.dart';

class MenuItem extends Equatable {
  final String title;
  final PuzzleDifficulty difficulty;

  const MenuItem({required this.title, required this.difficulty});

  @override
  List<Object?> get props => [title, difficulty];
}
