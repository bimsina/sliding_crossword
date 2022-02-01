// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crossword_puzzle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CrosswordPuzzle _$CrosswordPuzzleFromJson(Map<String, dynamic> json) =>
    CrosswordPuzzle(
      title: json['title'] as String,
      across: (json['across'] as List<dynamic>?)
              ?.map((e) => Question.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      down: (json['down'] as List<dynamic>?)
              ?.map((e) => Question.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      gridSize: json['grid_size'] as int,
      id: json['id'] as String,
      authorId: json['author_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      timesPlayed: json['times_played'] as int? ?? 0,
      maxSecondsAvailable: json['max_seconds_available'] as int?,
      maxMovesAvailable: json['max_moves_available'] as int?,
    );

Map<String, dynamic> _$CrosswordPuzzleToJson(CrosswordPuzzle instance) {
  final val = <String, dynamic>{
    'grid_size': instance.gridSize,
    'id': instance.id,
    'title': instance.title,
    'across': instance.across.map((e) => e.toJson()).toList(),
    'down': instance.down.map((e) => e.toJson()).toList(),
    'author_id': instance.authorId,
    'created_at': instance.createdAt.toIso8601String(),
    'times_played': instance.timesPlayed,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('max_seconds_available', instance.maxSecondsAvailable);
  writeNotNull('max_moves_available', instance.maxMovesAvailable);
  return val;
}
