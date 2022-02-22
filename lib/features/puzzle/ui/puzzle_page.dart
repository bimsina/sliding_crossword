import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sliding_crossword/core/ui/responsive_builder.dart';
import 'package:sliding_crossword/features/puzzle/models/puzzle/puzzle.dart';
import 'package:sliding_crossword/features/puzzle/state/puzzle_state.dart';

import 'widgets/across_and_down_indexes.dart';
import 'widgets/prompt_selector.dart';
import 'widgets/puzzle_widget.dart';
import 'widgets/timer_and_moves.dart';

class PuzzlePage extends StatelessWidget {
  final Puzzle puzzle;

  /// Add support for a [puzzleId] to be passed in
  const PuzzlePage({Key? key, required this.puzzle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PuzzleState>(
      create: (context) => PuzzleState(puzzle, context),
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
                ? FontAwesomeIcons.pauseCircle
                : FontAwesomeIcons.playCircle),
          ),
          _puzzleState.puzzle is! CrosswordPuzzle
              ? const SizedBox.shrink()
              : PopupMenuButton<int>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    switch (value) {
                      case 0:
                        _puzzleState.showHints = !_puzzleState.showHints;
                        break;
                      default:
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 0,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_puzzleState.showHints
                              ? Icons.visibility_off
                              : Icons.visibility),
                          const SizedBox(width: 8),
                          Text(_puzzleState.showHints
                              ? "Hide Hints"
                              : "Show Hints")
                        ],
                      ),
                    )
                  ],
                )
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
                                            : const _MainPuzzleBody()),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: _MainPuzzleBody()),
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
                            .withOpacity(0.2),
                        borderRadius:
                            _puzzleState.state == PuzzlePageState.playing
                                ? null
                                : BorderRadius.circular(8.0)),
                    child: IconButton(
                        autofocus: true,
                        iconSize: 150,
                        color: Theme.of(context).colorScheme.secondary,
                        onPressed: () {
                          _puzzleState.state = PuzzlePageState.playing;
                        },
                        tooltip: "Resume game",
                        icon: const Icon(FontAwesomeIcons.playCircle)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MainPuzzleBody extends StatefulWidget {
  const _MainPuzzleBody({Key? key}) : super(key: key);

  @override
  __MainPuzzleBodyState createState() => __MainPuzzleBodyState();
}

class __MainPuzzleBodyState extends State<_MainPuzzleBody> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final _puzzleState = context.read<PuzzleState>();
      final _emptyGridIndex =
          _puzzleState.tiles.indexOf(_puzzleState.emptyTile);
      final _gridSize = _puzzleState.gridSize;

      final physicalKey = event.data.physicalKey;
      int? _tileToMove;

      if (physicalKey == PhysicalKeyboardKey.arrowDown) {
        _tileToMove = _emptyGridIndex - _gridSize;
      } else if (physicalKey == PhysicalKeyboardKey.arrowUp) {
        _tileToMove = _emptyGridIndex + _gridSize;
      } else if (physicalKey == PhysicalKeyboardKey.arrowRight) {
        _tileToMove = _emptyGridIndex - 1;
      } else if (physicalKey == PhysicalKeyboardKey.arrowLeft) {
        _tileToMove = _emptyGridIndex + 1;
      }

      if (_tileToMove != null &&
          _tileToMove >= 0 &&
          _tileToMove < _gridSize * _gridSize) {
        _puzzleState.moveTile(_tileToMove);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final _puzzleState = Provider.of<PuzzleState>(context);

    return RawKeyboardListener(
      onKey: _handleKeyEvent,
      focusNode: _focusNode,
      child: LayoutBuilder(builder: (context, conxtraints) {
        if (!_focusNode.hasFocus) {
          FocusScope.of(context).requestFocus(_focusNode);
        }
        return PuzzleWidget(
          tileSize: conxtraints.maxWidth / _puzzleState.gridSize,
        );
      }),
    );
  }
}
