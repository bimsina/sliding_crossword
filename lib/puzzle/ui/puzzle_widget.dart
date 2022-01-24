import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_crossword/puzzle/models/tile.dart';
import 'package:sliding_crossword/puzzle/state/puzzle_state.dart';

class PuzzleWidget extends StatelessWidget {
  final double tileSize;

  const PuzzleWidget({
    Key? key,
    required this.tileSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _puzzleState = Provider.of<PuzzleState>(context);

    return Stack(
      children: _puzzleState.tiles.map((tile) {
        final index = _puzzleState.tiles.indexWhere((t) => t.id == tile.id);
        final _grid = _puzzleState.grids[index];

        /// Determine the direction where swiping should be allowed
        SwipeDirection _swipeDirection = SwipeDirection.none;
        final _emptyGridIndex =
            _puzzleState.tiles.indexOf(_puzzleState.emptyTile);

        final _emptyGrid = _puzzleState.grids[_emptyGridIndex];

        if (_grid.x == _emptyGrid.x) {
          /// Same column
          if (_grid.y < _emptyGrid.y) {
            _swipeDirection = SwipeDirection.down;
          } else if (_grid.y > _emptyGrid.y) {
            _swipeDirection = SwipeDirection.up;
          }
        } else if (_grid.y == _emptyGrid.y) {
          /// Same row
          if (_grid.x < _emptyGrid.x) {
            _swipeDirection = SwipeDirection.right;
          } else if (_grid.x > _emptyGrid.x) {
            _swipeDirection = SwipeDirection.left;
          }
        }

        return AnimatedPositioned(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOutCubicEmphasized,
          left: _grid.x * tileSize,
          top: _grid.y * tileSize,
          key: Key(tile.id),
          child: _PuzzleTile(
            key: ValueKey(index),
            tileSize: tileSize,
            swipeDirection: _swipeDirection,
            tile: tile,
            tileColor: _puzzleState.correctColumns.contains(_grid.x) ||
                    _puzzleState.correctRows.contains(_grid.y)
                ? Colors.green
                : null,
            onTap: () {
              _puzzleState.moveTile(index);
            },
          ),
        );
      }).toList(),
    );
  }
}

class _PuzzleTile extends StatelessWidget {
  final double tileSize;
  final Tile tile;
  final SwipeDirection swipeDirection;
  final VoidCallback? onTap;
  final Color? tileColor;

  const _PuzzleTile({
    Key? key,
    required this.tileSize,
    required this.tile,
    required this.onTap,
    this.swipeDirection = SwipeDirection.none,
    this.tileColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _puzzleState = Provider.of<PuzzleState>(context);

    return SizedBox(
      height: tileSize,
      width: tileSize,
      child: tile.value == null
          ? const SizedBox.shrink()
          : MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onTap,
                onHorizontalDragEnd: (swipeDirection == SwipeDirection.left ||
                        swipeDirection == SwipeDirection.right)
                    ? (details) {
                        if ((details.velocity.pixelsPerSecond.dx > 10 &&
                                swipeDirection == SwipeDirection.right) ||
                            (details.velocity.pixelsPerSecond.dx < 10 &&
                                swipeDirection == SwipeDirection.left)) {
                          onTap?.call();
                        }
                      }
                    : null,
                onVerticalDragEnd: (swipeDirection == SwipeDirection.down ||
                        swipeDirection == SwipeDirection.up)
                    ? (details) {
                        if ((details.velocity.pixelsPerSecond.dy > 10 &&
                                swipeDirection == SwipeDirection.down) ||
                            (details.velocity.pixelsPerSecond.dy < 10 &&
                                swipeDirection == SwipeDirection.up)) {
                          onTap?.call();
                        }
                      }
                    : null,
                child: Card(
                  color: tileColor,
                  elevation: 0,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_puzzleState.showHints)
                        Positioned(
                            left: 4,
                            top: 4,
                            child: Text(
                              "${int.parse(tile.id) + 1}",
                              style: Theme.of(context).textTheme.caption,
                            )),
                      Center(
                        child: Text(
                          tile.value!.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
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

enum SwipeDirection { none, left, right, up, down }
