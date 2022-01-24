import 'package:equatable/equatable.dart';

class Grid extends Equatable {
  final int x;
  final int y;

  const Grid({required this.x, required this.y});

  @override
  List<Object?> get props => [x, y];

  @override
  String toString() => '($x, $y)';
}
