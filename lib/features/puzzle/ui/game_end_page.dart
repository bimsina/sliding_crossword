import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sliding_crossword/core/utils/date_utils.dart';
import 'package:sliding_crossword/features/puzzle/state/puzzle_state.dart';

class GameEndPagePayload {
  final PuzzleState puzzleState;
  final GameEndPageState gameEndPageState;

  GameEndPagePayload(this.puzzleState, this.gameEndPageState);
}

enum GameEndPageState {
  won,
  lossViaTimeout,
  lossViaNoMoreMoves,
}

class GameEndPage extends StatelessWidget {
  final GameEndPagePayload payload;
  const GameEndPage({Key? key, required this.payload}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        alignment: Alignment.center,
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                payload.gameEndPageState == GameEndPageState.won
                    ? "You Won!"
                    : "Sadly you lost!",
                style: Theme.of(context).textTheme.headline3),
            Container(
              constraints: const BoxConstraints(
                  maxHeight: 500, maxWidth: 500, minWidth: 250),
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      payload.gameEndPageState == GameEndPageState.won
                          ? "Well done!"
                          : "Oops! ${payload.gameEndPageState == GameEndPageState.lossViaTimeout ? "Times UP!!" : "Out of moves."}",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline5!.copyWith(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),
                  _TimeTaken(payload.puzzleState),
                  const SizedBox(height: 20),
                  _Moves(payload.puzzleState),
                ],
              ),
            ),
            FloatingActionButton.extended(
              heroTag: 'retry_button',
              onPressed: () {
                GoRouter.of(context).pop();
                GoRouter.of(context)
                    .push('/puzzle', extra: payload.puzzleState.puzzle);
              },
              icon: const Icon(Icons.sync),
              label: const Text('Retry'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                  onPressed: () {
                    GoRouter.of(context).pop();
                  },
                  child: const Text("No thanks")),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeTaken extends StatelessWidget {
  final PuzzleState _puzzleState;
  const _TimeTaken(this._puzzleState, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.hourglass_bottom_rounded,
          size: 30,
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        const SizedBox(width: 8),
        Text(
            _puzzleState.timeElapsed.inHours > 0
                ? _puzzleState.timeElapsed.toHMS()
                : _puzzleState.timeElapsed.toMS(),
            style: TextStyle(
                fontSize: 30,
                color: Theme.of(context).scaffoldBackgroundColor,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _Moves extends StatelessWidget {
  final PuzzleState _puzzleState;
  const _Moves(this._puzzleState, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Moves : " + _puzzleState.moves.toString(),
            style: TextStyle(
                fontSize: 24,
                color: Theme.of(context).scaffoldBackgroundColor,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}
