import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_crossword/features/puzzle/models/crossword_puzzle/crossword_puzzle.dart';
import 'package:sliding_crossword/features/puzzle/state/puzzle_state.dart';

const _startWidth = 30.0;

class DownIndexes extends StatelessWidget {
  const DownIndexes({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _puzzleState = Provider.of<PuzzleState>(context);

    return SizedBox(
      height: _startWidth,
      child: Row(
        children: [
          const SizedBox(width: _startWidth, height: _startWidth),
          ...List.generate(_puzzleState.gridSize, (i) {
            final _prompt = (_puzzleState.puzzle as CrosswordPuzzle)
                .down
                .firstWhereOrNull((element) => element.id == "down_$i");

            return Expanded(
              child: _prompt == null || _prompt.prompt == "-"
                  ? const SizedBox.shrink()
                  : _SingleIndex(
                      key: Key(i.toString()),
                      index: i,
                      highlight: _puzzleState.selectedPrompt?.id == 'down_$i',
                      isSolved: _puzzleState.correctColumns.contains(i),
                      onTap: () {
                        if (_puzzleState.selectedPrompt == null) {
                          _puzzleState.selectedPrompt = _prompt;
                        } else {
                          final int _index = _puzzleState.availablePrompts
                              .indexWhere((element) => element.id == 'down_$i');
                          if (_index == -1) return;
                          _puzzleState.jumpToPrompt(_index);
                        }
                      },
                    ),
            );
          }),
        ],
      ),
    );
  }
}

class AcrossIndexes extends StatelessWidget {
  const AcrossIndexes({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _puzzleState = Provider.of<PuzzleState>(context);
    return SizedBox(
      width: _startWidth,
      child: Column(
          children: List.generate(_puzzleState.gridSize, (i) {
        final _prompt = (_puzzleState.puzzle as CrosswordPuzzle)
            .across
            .firstWhereOrNull((element) => element.id == "across_$i");

        return Expanded(
          child: _prompt == null || _prompt.prompt == "-"
              ? const SizedBox.shrink()
              : _SingleIndex(
                  index: i,
                  key: Key((i + _puzzleState.gridSize).toString()),
                  highlight: _puzzleState.selectedPrompt?.id == 'across_$i',
                  isSolved: _puzzleState.correctRows.contains(i),
                  onTap: () {
                    final int _index = _puzzleState.availablePrompts
                        .indexWhere((element) => element.id == 'across_$i');
                    if (_index == -1) return;
                    _puzzleState.jumpToPrompt(_index);
                  },
                ),
        );
      }).toList()),
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
    final _accentColor = Theme.of(context).colorScheme.secondary;
    return Center(
      child: InkResponse(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: highlight
                  ? _accentColor
                  : isSolved
                      ? _accentColor
                      : Colors.transparent,
              border: highlight ? Border.all(color: _accentColor) : null),
          child: isSolved
              ? Icon(Icons.done,
                  color: Theme.of(context).scaffoldBackgroundColor)
              : Text(
                  "${index + 1}",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: highlight
                          ? Theme.of(context).scaffoldBackgroundColor
                          : null),
                  textAlign: TextAlign.center,
                ),
        ),
      ),
    );
  }
}
