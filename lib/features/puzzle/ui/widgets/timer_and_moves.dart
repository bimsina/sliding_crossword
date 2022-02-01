import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_crossword/core/utils/date_utils.dart';
import 'package:sliding_crossword/features/puzzle/models/crossword_puzzle/crossword_puzzle.dart';
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
            if (_puzzleState.puzzle is CrosswordPuzzle)
              const _TotalDuration()
            else
              const _ElapsedTime()
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Moves: ", style: TextStyle(fontSize: 18)),
            Text(
              '${_puzzleState.moves}',
              style: const TextStyle(fontSize: 18),
            ),
            if (_puzzleState.puzzle is CrosswordPuzzle)
              _MaxMoves(puzzle: _puzzleState.puzzle as CrosswordPuzzle)
          ],
        )
      ],
    );
  }
}

class _ElapsedTime extends StatelessWidget {
  const _ElapsedTime({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _puzzleState = Provider.of<PuzzleState>(context);

    return Text(
        _puzzleState.timeElapsed.inHours > 0
            ? _puzzleState.timeElapsed.toHMS()
            : _puzzleState.timeElapsed.toMS(),
        style: const TextStyle(fontSize: 30));
  }
}

class _TotalDuration extends StatelessWidget {
  const _TotalDuration({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _puzzleState = Provider.of<PuzzleState>(context);
    final _puzzle = _puzzleState.puzzle as CrosswordPuzzle;

    if (_puzzle.maxSecondsAvailable == null) return const _ElapsedTime();
    final Duration _duration = Duration(seconds: _puzzle.maxSecondsAvailable!) -
        _puzzleState.timeElapsed;
    return Text(
        "${_duration.inMinutes.remainder(60)}m ${(_duration.inSeconds.remainder(60))}s",
        style: const TextStyle(fontSize: 24));
  }
}

class _MaxMoves extends StatelessWidget {
  final CrosswordPuzzle puzzle;
  const _MaxMoves({Key? key, required this.puzzle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (puzzle.maxMovesAvailable == null) return const SizedBox.shrink();
    return Text(
      ' / ${puzzle.maxMovesAvailable}',
      style: const TextStyle(fontSize: 18),
    );
  }
}
