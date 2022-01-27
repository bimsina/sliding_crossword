import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

class AcrossIndexes extends StatelessWidget {
  const AcrossIndexes({Key? key}) : super(key: key);

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
    final _accentColor = Theme.of(context).colorScheme.secondary;
    return Center(
      child: InkResponse(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: highlight ? Border.all(color: _accentColor) : null),
          child: isSolved
              ? Icon(
                  Icons.done,
                  color: _accentColor,
                )
              : Text(
                  "${index + 1}",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: highlight ? _accentColor : null),
                  textAlign: TextAlign.center,
                ),
        ),
      ),
    );
  }
}
