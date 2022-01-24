// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crossword_puzzle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CrosswordPuzzle _$CrosswordPuzzleFromJson(Map<String, dynamic> json) =>
    CrosswordPuzzle(
      title: json['title'] as String,
      across: (json['across'] as List<dynamic>)
          .map((e) => Question.fromJson(e as Map<String, dynamic>))
          .toList(),
      down: (json['down'] as List<dynamic>)
          .map((e) => Question.fromJson(e as Map<String, dynamic>))
          .toList(),
      gridSize: json['grid_size'] as int,
    );

Map<String, dynamic> _$CrosswordPuzzleToJson(CrosswordPuzzle instance) =>
    <String, dynamic>{
      'grid_size': instance.gridSize,
      'title': instance.title,
      'across': instance.across,
      'down': instance.down,
    };
