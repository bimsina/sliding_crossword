import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'question.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class Question extends Equatable {
  final String id;
  final String prompt;
  final String answer;

  const Question({
    required this.id,
    required this.prompt,
    required this.answer,
  });

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionToJson(this);

  @override
  List<Object?> get props => [id];
}
