import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_crossword/core/ui/responsive_builder.dart';
import 'package:sliding_crossword/puzzle/models/puzzle/puzzle.dart';
import 'package:sliding_crossword/puzzle/state/puzzle_state.dart';
import 'package:sliding_crossword/puzzle/ui/widgets/across_and_down_indexes.dart';
import 'package:sliding_crossword/puzzle/ui/widgets/puzzle_widget.dart';
import 'package:sliding_crossword/puzzle/ui/widgets/timer_and_moves.dart';

import 'widgets/prompt_selector.dart';

class PuzzlePage extends StatelessWidget {
  final Puzzle puzzle;
  const PuzzlePage({Key? key, required this.puzzle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PuzzleState>(
      create: (_) => PuzzleState(puzzle),
      child: const PuzzlePagePresenter(),
    );
  }
}

class PuzzlePagePresenter extends StatelessWidget {
  const PuzzlePagePresenter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _puzzleState = Provider.of<PuzzleState>(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: 'Pause Game',
            onPressed: () {
              if (_puzzleState.state == PuzzlePageState.playing) {
                _puzzleState.state = PuzzlePageState.paused;
              } else {
                _puzzleState.state = PuzzlePageState.playing;
              }
            },
            icon: Icon(_puzzleState.state == PuzzlePageState.playing
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded),
          ),
        ],
      ),
      body: SafeArea(
          child: ResponsiveLayoutBuilder(
        small: (context, child) => Column(
          children: const [
            Expanded(child: TimerAndMoves()),
            Expanded(flex: 5, child: _MainPuzzle()),
            PromptSelector(),
          ],
        ),
        medium: (context, child) => Column(
          children: const [
            Expanded(child: TimerAndMoves()),
            Expanded(flex: 5, child: _MainPuzzle()),
            PromptSelector(),
          ],
        ),
        large: (context, child) => Row(
          children: [
            const Expanded(child: TimerAndMoves()),
            Expanded(
                flex: 2,
                child: Column(
                  children: const [
                    Expanded(child: _MainPuzzle()),
                    PromptSelector(),
                  ],
                )),
          ],
        ),
      )),
    );
  }
}

class _MainPuzzle extends StatelessWidget {
  const _MainPuzzle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _puzzleState = Provider.of<PuzzleState>(context);
    final _isCrossword = _puzzleState.puzzle is CrosswordPuzzle;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Container(
          alignment: Alignment.center,
          constraints: const BoxConstraints(maxWidth: 500),
          child: AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: [
                IgnorePointer(
                  ignoring: _puzzleState.state == PuzzlePageState.paused,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    child: _isCrossword
                        ? Column(
                            children: [
                              const DownIndexes(),
                              const SizedBox(height: 8),
                              Expanded(
                                child: Row(
                                  children: [
                                    const AcrossIndexes(),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _puzzleState.tiles.isEmpty
                                          ? const SizedBox.shrink()
                                          : _mainPuzzle(
                                              context, _puzzleState.gridSize),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _mainPuzzle(context, _puzzleState.gridSize),
                          ),
                  ),
                ),
                AnimatedScale(
                  scale: _puzzleState.state == PuzzlePageState.playing ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOutQuad,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                        shape: _puzzleState.state == PuzzlePageState.playing
                            ? BoxShape.circle
                            : BoxShape.rectangle,
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.4),
                        borderRadius:
                            _puzzleState.state == PuzzlePageState.playing
                                ? null
                                : BorderRadius.circular(8.0)),
                    child: IconButton(
                        autofocus: true,
                        iconSize: 150,
                        onPressed: () {
                          _puzzleState.state = PuzzlePageState.playing;
                        },
                        tooltip: "Resume game",
                        icon: Icon(
                          Icons.play_arrow_rounded,
                          color: Theme.of(context).scaffoldBackgroundColor,
                        )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _mainPuzzle(BuildContext context, int gridSize) =>
      LayoutBuilder(builder: (context, conxtraints) {
        return PuzzleWidget(
          tileSize: conxtraints.maxWidth / gridSize,
        );
      });
}
