import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class CustomTheme extends Equatable {
  final String id;
  final Color backgroundColor;
  final Color tileColor;
  final Brightness brightness;
  final Color accentColor;

  const CustomTheme(
      {required this.id,
      required this.backgroundColor,
      required this.tileColor,
      required this.brightness,
      required this.accentColor});

  @override
  List<Object?> get props => [id];
}
