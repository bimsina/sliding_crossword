import 'package:equatable/equatable.dart';

class Tile extends Equatable {
  final String id;
  final String? value;
  final bool canInteract;

  const Tile(
      {required this.value, required this.id, required this.canInteract});

  @override
  List<Object?> get props => [id];
}
