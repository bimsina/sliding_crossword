import 'package:json_annotation/json_annotation.dart';
import 'package:sliding_crossword/features/puzzle/models/puzzle/puzzle.dart';
export 'question/question.dart';

part 'crossword_puzzle.g.dart';

@JsonSerializable(
    fieldRename: FieldRename.snake, includeIfNull: false, explicitToJson: true)
class CrosswordPuzzle extends Puzzle {
  final String id;
  final String title;

  @JsonKey(defaultValue: [])
  final List<Question> across;

  @JsonKey(defaultValue: [])
  final List<Question> down;

  final String authorId;

  final DateTime createdAt;

  @JsonKey(defaultValue: 0)
  final int timesPlayed;

  final int? maxSecondsAvailable;

  final int? maxMovesAvailable;

  CrosswordPuzzle({
    required this.title,
    required this.across,
    required this.down,
    required int gridSize,
    required this.id,
    required this.authorId,
    required this.createdAt,
    this.timesPlayed = 0,
    this.maxSecondsAvailable,
    this.maxMovesAvailable,
  }) : super(gridSize: gridSize);

  factory CrosswordPuzzle.fromJson(Map<String, dynamic> json) =>
      _$CrosswordPuzzleFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CrosswordPuzzleToJson(this);
}
