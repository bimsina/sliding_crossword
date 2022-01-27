import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_crossword/features/puzzle/state/puzzle_state.dart';

class TimerAndMoves extends StatelessWidget {
  const TimerAndMoves({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _puzzleState = Provider.of<PuzzleState>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timer, size: 30),
            const SizedBox(width: 8),
            Text(
                "${_puzzleState.timeElapsed.inMinutes.remainder(60)}m ${(_puzzleState.timeElapsed.inSeconds.remainder(60))}s",
                style: const TextStyle(fontSize: 30))
          ],
        ),
        const SizedBox(height: 10),
        Text("Moves: ${_puzzleState.moves}",
            style: const TextStyle(fontSize: 18))
      ],
    );
  }
}
