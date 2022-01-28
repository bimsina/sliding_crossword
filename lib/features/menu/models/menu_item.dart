import 'package:equatable/equatable.dart';

class MenuItem extends Equatable {
  final String title;
  final int gridSize;
  final bool? isNew;

  const MenuItem(
      {required this.title, required this.gridSize, this.isNew = false});

  @override
  List<Object?> get props => [title, gridSize, isNew];
}
