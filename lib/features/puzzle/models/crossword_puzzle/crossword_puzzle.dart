import 'package:json_annotation/json_annotation.dart';
import 'package:sliding_crossword/features/puzzle/models/puzzle/puzzle.dart';
export 'question/question.dart';

part 'crossword_puzzle.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class CrosswordPuzzle extends Puzzle {
  final String title;

  final List<Question> across;
  final List<Question> down;

  CrosswordPuzzle({
    required this.title,
    required this.across,
    required this.down,
    required int gridSize,
  }) : super(gridSize: gridSize) {
    assert(gridSize > 0);
    assert(across.length == gridSize);
    assert(down.length == gridSize);
  }

  factory CrosswordPuzzle.fromJson(Map<String, dynamic> json) =>
      _$CrosswordPuzzleFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CrosswordPuzzleToJson(this);
}
