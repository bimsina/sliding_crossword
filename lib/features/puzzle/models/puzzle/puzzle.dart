import 'package:json_annotation/json_annotation.dart';
export '../crossword_puzzle/crossword_puzzle.dart';
part 'puzzle.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class Puzzle {
  final int gridSize;

  Puzzle({
    required this.gridSize,
  });

  factory Puzzle.fromJson(Map<String, dynamic> json) => _$PuzzleFromJson(json);

  Map<String, dynamic> toJson() => _$PuzzleToJson(this);
}
