import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_crossword/features/puzzle/models/puzzle/puzzle.dart';
import 'package:sliding_crossword/features/puzzle/state/puzzle_state.dart';

class HintsAndInfoRow extends StatelessWidget {
  const HintsAndInfoRow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _puzzleState = Provider.of<PuzzleState>(context);

    if (_puzzleState.puzzle is! CrosswordPuzzle) {
      return const SizedBox();
    }
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _SingleRoundedButton(
            tooltip: "Show Hint",
            icon: Icons.help,
            onPressed: () {},
            notificationCount: 10,
          ),
        ],
      ),
    );
  }
}

class _SingleRoundedButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final int? notificationCount;

  const _SingleRoundedButton(
      {Key? key,
      required this.onPressed,
      required this.icon,
      required this.tooltip,
      this.notificationCount})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              shape: BoxShape.circle),
          child: IconButton(
            tooltip: tooltip,
            onPressed: onPressed,
            icon: Icon(
              icon,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
        if (notificationCount != null)
          Positioned(
            right: 8,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 12,
                  minHeight: 12,
                ),
                child: Text(
                  '$notificationCount',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
      ],
    );
  }
}
