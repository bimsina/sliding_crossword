import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sliding_crossword/core/state/puzzle_list_state.dart';
import 'package:sliding_crossword/features/menu/models/menu_item.dart';
import 'package:sliding_crossword/features/puzzle/models/puzzle/puzzle.dart';

class PuzzlesListSelectorPage extends StatelessWidget {
  final MenuItem item;

  const PuzzlesListSelectorPage({Key? key, required this.item})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _allPuzzles = Provider.of<PuzzleListState>(context).puzzles;
    final _puzzles = _allPuzzles
        .where((puzzle) => puzzle.gridSize == item.gridSize)
        .toList();
    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: SafeArea(
        child: Center(
          child: Center(
              child: _puzzles.isEmpty
                  ? const Text("No Puzzles Found")
                  : PuzzlesGrid(puzzles: _puzzles)
              // : Padding(
              //     padding: const EdgeInsets.all(8.0),
              //     child: ListView.builder(
              //       shrinkWrap: true,
              //       controller: _scrollController,
              //       itemCount: _puzzles.length,
              //       itemBuilder: (BuildContext context, int index) {
              //         return Card(
              //           elevation: 0,
              //           child: ListTile(
              //             title: Text(
              //               _puzzles[index].title,
              //               textAlign: TextAlign.center,
              //             ),
              //             trailing:
              //                 const Icon(Icons.arrow_forward_ios, size: 16),
              //             onTap: () {
              //               context.router.push(
              //                   PuzzlePageRoute(puzzle: _puzzles[index]));
              //             },
              //           ),
              //         );
              //       },
              // ),
              // ),
              ),
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
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      physics: const BouncingScrollPhysics(),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemCount: puzzles.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              context.push('/puzzle', extra: puzzles[index]);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  puzzles[index].title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline6,
                ),
                const SizedBox(height: 10),
                Text("${puzzles[index].gridSize}x${puzzles[index].gridSize}",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.subtitle1),
              ],
            ),
          ),
        );
      },
    );
  }
}
