import 'package:equatable/equatable.dart';

class Tile extends Equatable {
  final String id;
  final String? value;

  const Tile({required this.value, required this.id});

  @override
  List<Object?> get props => [id];
}
