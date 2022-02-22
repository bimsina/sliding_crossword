import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sliding_crossword/core/enums/data_fetch_state.dart';
import 'package:sliding_crossword/features/dialogs/ui/loading_indicator.dart';
import 'package:sliding_crossword/features/puzzle/models/puzzle/puzzle.dart';
import 'package:sliding_crossword/features/puzzles_list/models/sort_direction.dart';
import 'package:sliding_crossword/features/puzzles_list/models/sort_order.dart';
import 'package:sliding_crossword/features/puzzles_list/state/puzzles_list_state.dart';
import 'package:sliding_crossword/features/puzzles_list/models/puzzles_list_filter.dart';
export 'package:sliding_crossword/features/puzzles_list/models/puzzles_list_filter.dart';

class PuzzlesListPage extends StatefulWidget {
  final VoidCallback? onClose;
  const PuzzlesListPage({Key? key, this.onClose}) : super(key: key);

  @override
  State<PuzzlesListPage> createState() => PuzzlesListPageState();
}

class PuzzlesListPageState extends State<PuzzlesListPage> {
  @override
  Widget build(BuildContext context) {
    final _state = Provider.of<PuzzleListState>(context);

    return Scaffold(
      appBar: AppBar(
        leading: widget.onClose == null
            ? null
            : IconButton(
                onPressed: widget.onClose, icon: const Icon(Icons.close)),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => _FilterDialog(
                  filter: _state.filter ?? const PuzzlesListFilter(),
                  onFilterChanged: (filter) {
                    _state.filter = filter;
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: _state.state == DataFetchState.loading
              ? const CustomLoadingIndicator()
              : _state.state == DataFetchState.error
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "Oops, something went wrong!",
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ),
                        ElevatedButton.icon(
                            onPressed: () {
                              _state.fetchPuzzles();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text("Retry"))
                      ],
                    )
                  : PuzzlesGrid(puzzles: _state.puzzlesList),
        ),
      ),
    );
  }
}

class PuzzlesGrid extends StatelessWidget {
  final List<CrosswordPuzzle> puzzles;
  const PuzzlesGrid({Key? key, required this.puzzles}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return puzzles.isEmpty
        ? const Center(child: Text("No puzzles found"))
        : LayoutBuilder(builder: (context, constraints) {
            return GridView.builder(
              padding: const EdgeInsets.all(8),
              physics: const BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: constraints.maxWidth ~/ 150),
              itemCount: puzzles.length,
              itemBuilder: (BuildContext context, int index) {
                final _puzzle = puzzles[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      context.push('/puzzle', extra: _puzzle);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _puzzle.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        const SizedBox(height: 10),
                        Text("${_puzzle.gridSize}x${_puzzle.gridSize}",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.subtitle1),
                      ],
                    ),
                  ),
                );
              },
            );
          });
  }
}

class _FilterDialog extends StatefulWidget {
  final PuzzlesListFilter filter;
  final Function(PuzzlesListFilter) onFilterChanged;

  const _FilterDialog(
      {Key? key, required this.filter, required this.onFilterChanged})
      : super(key: key);

  @override
  __FilterDialogState createState() => __FilterDialogState();
}

class __FilterDialogState extends State<_FilterDialog> {
  late PuzzlesListFilter _filter;
  @override
  void initState() {
    _filter = widget.filter;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      actionsPadding: const EdgeInsets.only(bottom: 16.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: const [
              Text(
                "Difficulty",
                textAlign: TextAlign.left,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ToggleButtons(
            onPressed: (index) {
              setState(() {
                _filter = _filter.copyWith(
                    difficulty: PuzzleDifficulty.values[index]);
              });
            },
            children: PuzzleDifficulty.values
                .map((e) => Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(e.name.capitalize()),
                    ))
                .toList(),
            isSelected: PuzzleDifficulty.values
                .map(
                  (difficulty) => difficulty == _filter.difficulty,
                )
                .toList(),
          ),
          const Divider(),
          Row(
            children: const [
              Text(
                "Sort by",
                textAlign: TextAlign.left,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ToggleButtons(
            onPressed: (index) {
              setState(() {
                _filter = _filter.copyWith(sortOrder: SortOrder.values[index]);
              });
            },
            children: SortOrder.values
                .map((e) => Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(e.name.capitalize()),
                    ))
                .toList(),
            isSelected: SortOrder.values
                .map(
                  (order) => order == _filter.sortOrder,
                )
                .toList(),
          ),
          const Divider(),
          Row(
            children: const [
              Text(
                "Sort order",
                textAlign: TextAlign.left,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ToggleButtons(
            onPressed: (index) {
              setState(() {
                _filter = _filter.copyWith(
                    sortDirection: SortDirection.values[index]);
              });
            },
            children: SortDirection.values
                .map((e) => Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(e.name.capitalize()),
                    ))
                .toList(),
            isSelected: SortDirection.values
                .map(
                  (dir) => dir == _filter.sortDirection,
                )
                .toList(),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        FloatingActionButton.extended(
          heroTag: "update_filter",
          onPressed: () {
            widget.onFilterChanged(_filter);
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.done),
          label: const Text("Update"),
        )
      ],
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
