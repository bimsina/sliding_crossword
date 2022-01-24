import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_crossword/core/ui/responsive_builder.dart';
import 'package:sliding_crossword/puzzle/models/puzzle/puzzle.dart';
import 'package:sliding_crossword/puzzle/state/puzzle_state.dart';
import 'package:sliding_crossword/puzzle/ui/puzzle_widget.dart';

const _startWidth = 30.0;

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
            Expanded(child: _TimerAndMoves()),
            Expanded(flex: 5, child: _MainPuzzle()),
            _PromptSelector(),
          ],
        ),
        medium: (context, child) => Column(
          children: const [
            Expanded(child: _TimerAndMoves()),
            Expanded(flex: 5, child: _MainPuzzle()),
            _PromptSelector(),
          ],
        ),
        large: (context, child) => Column(
          children: [
            Expanded(
                child: Row(
              children: const [
                Expanded(child: _TimerAndMoves()),
                Expanded(flex: 2, child: _MainPuzzle()),
              ],
            )),
            const _PromptSelector(),
          ],
        ),
      )),
    );
  }
}

class _TimerAndMoves extends StatelessWidget {
  const _TimerAndMoves({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _puzzleState = Provider.of<PuzzleState>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.timer, size: 30),
            SizedBox(width: 8),
            Text('00:00', style: TextStyle(fontSize: 30))
          ],
        ),
        const SizedBox(height: 10),
        Text("Moves: ${_puzzleState.moves}",
            style: const TextStyle(fontSize: 18))
      ],
    );
  }
}

class _PromptSelector extends StatelessWidget {
  const _PromptSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _puzzleState = Provider.of<PuzzleState>(context);

    if (_puzzleState.puzzle is! CrosswordPuzzle) {
      return const SizedBox();
    }

    final _prompts = [
      ...(_puzzleState.puzzle as CrosswordPuzzle).down,
      ...(_puzzleState.puzzle as CrosswordPuzzle).across
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            _puzzleState.showHints = !_puzzleState.showHints;
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_puzzleState.showHints
                    ? Icons.visibility_off
                    : Icons.visibility),
                const SizedBox(width: 8),
                Text(_puzzleState.showHints ? "Hide Hints" : "Show Hints")
              ],
            ),
          ),
        ),
        _PromptSelectorPresenter(
          key: const Key('prompt-selector'),
          prompts: _prompts,
          controller: _puzzleState.promptController,
          onPromptChanged: _puzzleState.jumpToPrompt,
          onPageChanged: (page) {
            _puzzleState.highlightedPrompt = page;
          },
        ),
      ],
    );
  }
}

class _PromptSelectorPresenter extends StatelessWidget {
  final List<Question> prompts;
  final PageController controller;
  final Function(int) onPromptChanged;
  final Function(int) onPageChanged;

  const _PromptSelectorPresenter({
    Key? key,
    required this.prompts,
    required this.controller,
    required this.onPromptChanged,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      constraints: const BoxConstraints(maxWidth: 500),
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 0,
        child: Row(
          children: [
            IconButton(
                iconSize: 16,
                onPressed: () {
                  if (controller.page == 0) {
                    onPromptChanged(prompts.length - 1);
                  } else {
                    if (controller.page == null) return;
                    onPromptChanged((controller.page! - 1).toInt());
                  }
                },
                icon: const Icon(Icons.arrow_back_ios)),
            Expanded(
              child: PageView.builder(
                  controller: controller,
                  itemCount: prompts.length,
                  onPageChanged: onPageChanged,
                  itemBuilder: (context, index) {
                    return Center(
                      child: Text(
                        prompts[index].prompt,
                        style: const TextStyle(fontSize: 18),
                      ),
                    );
                  }),
            ),
            IconButton(
                iconSize: 16,
                onPressed: () {
                  if (controller.page == prompts.length - 1) {
                    onPromptChanged(0);
                  } else {
                    if (controller.page == null) return;
                    onPromptChanged((controller.page! + 1).toInt());
                  }
                },
                icon: const Icon(Icons.arrow_forward_ios)),
          ],
        ),
      ),
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
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: _isCrossword
                      ? Column(
                          children: [
                            const _DownIndexes(),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Row(
                                children: [
                                  const _AcrossIndexes(),
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
                AnimatedScale(
                  scale: _puzzleState.state == PuzzlePageState.playing ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOutQuad,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(8.0)),
                    child: IconButton(
                        autofocus: true,
                        iconSize: 150,
                        onPressed: () {
                          _puzzleState.state = PuzzlePageState.playing;
                        },
                        tooltip: "Resume game",
                        icon: const Icon(Icons.play_arrow_rounded)),
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

class _DownIndexes extends StatelessWidget {
  const _DownIndexes({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _puzzleState = Provider.of<PuzzleState>(context);

    return SizedBox(
      height: _startWidth,
      child: Row(
        children: [
          const SizedBox(width: _startWidth, height: _startWidth),
          for (int i = 0; i < _puzzleState.gridSize; i++)
            Expanded(
              child: _SingleIndex(
                key: Key(i.toString()),
                index: i,
                highlight: i == _puzzleState.highlightedPrompt,
                isSolved: _puzzleState.correctColumns.contains(i),
                onTap: () {
                  _puzzleState.jumpToPrompt(i);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _AcrossIndexes extends StatelessWidget {
  const _AcrossIndexes({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _puzzleState = Provider.of<PuzzleState>(context);
    return SizedBox(
      width: _startWidth,
      child: Column(
        children: [
          for (int i = 0; i < _puzzleState.gridSize; i++)
            Expanded(
              child: _SingleIndex(
                index: i,
                key: Key((i + _puzzleState.gridSize).toString()),
                highlight:
                    i + _puzzleState.gridSize == _puzzleState.highlightedPrompt,
                isSolved: _puzzleState.correctRows.contains(i),
                onTap: () {
                  _puzzleState.jumpToPrompt(i + _puzzleState.gridSize);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _SingleIndex extends StatelessWidget {
  final int index;
  final bool isSolved;
  final bool highlight;
  final VoidCallback onTap;

  const _SingleIndex(
      {Key? key,
      required this.index,
      this.isSolved = false,
      this.highlight = false,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkResponse(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: highlight ? Border.all(color: Colors.green) : null),
          child: isSolved
              ? const Icon(
                  Icons.done,
                  color: Colors.green,
                )
              : Text(
                  "${index + 1}",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: highlight ? Colors.green : null),
                  textAlign: TextAlign.center,
                ),
        ),
      ),
    );
  }
}
