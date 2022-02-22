import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sliding_crossword/core/state/user_state.dart';
import 'package:sliding_crossword/features/puzzle/models/puzzle/puzzle.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _userState = Provider.of<UserState>(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Admin")),
      body: _userState.isAdmin
          ? _PuzzlesList()
          : const Center(child: Text("Not admin")),
    );
  }
}

class _PuzzlesList extends StatelessWidget {
  _PuzzlesList({Key? key}) : super(key: key);

  final Stream<QuerySnapshot> _puzzlesStream = FirebaseFirestore.instance
      .collection('puzzles_under_review')
      .withConverter<CrosswordPuzzle>(
          fromFirestore: (snapshot, options) =>
              CrosswordPuzzle.fromJson(snapshot.data()!),
          toFirestore: (puzzle, options) => puzzle.toJson())
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _puzzlesStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.data == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: snapshot.data!.docs.map((document) {
            final _puzzle = document.data() as CrosswordPuzzle;
            return _SinglePuzzle(puzzle: _puzzle, id: document.id);
          }).toList(),
        );
      },
    );
  }
}

class _SinglePuzzle extends StatefulWidget {
  final CrosswordPuzzle puzzle;
  final String id;

  const _SinglePuzzle({Key? key, required this.puzzle, required this.id})
      : super(key: key);

  @override
  State<_SinglePuzzle> createState() => _SinglePuzzleState();
}

class _SinglePuzzleState extends State<_SinglePuzzle> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.puzzle.title),
      subtitle: Text("${widget.puzzle.gridSize}x${widget.puzzle.gridSize}"),
      onTap: () {
        GoRouter.of(context).push('/puzzle', extra: widget.puzzle);
      },
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            label: const Text("Approve"),
            onPressed: _isLoading
                ? null
                : () async {
                    setState(() {
                      _isLoading = true;
                    });
                    final _puzzleDoc = FirebaseFirestore.instance
                        .collection('puzzles')
                        .doc(widget.id)
                        .withConverter<CrosswordPuzzle>(
                            fromFirestore: (snapshot, options) =>
                                CrosswordPuzzle.fromJson(snapshot.data()!),
                            toFirestore: (puzzle, options) => puzzle.toJson());
                    final _currentDoc = FirebaseFirestore.instance
                        .collection('puzzles_under_review')
                        .doc(widget.id);

                    await Future.wait([
                      _puzzleDoc.set(widget.puzzle),
                      _currentDoc.delete()
                    ]).then((value) {
                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    });
                  },
            icon: _isLoading
                ? const CircularProgressIndicator()
                : const Icon(Icons.done),
          ),
          IconButton(
            onPressed: _isLoading
                ? null
                : () async {
                    setState(() {
                      _isLoading = true;
                    });

                    final _currentDoc = FirebaseFirestore.instance
                        .collection('puzzles_under_review')
                        .doc(widget.id);
                    _currentDoc.delete().then((value) {
                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    });
                  },
            icon: _isLoading
                ? const CircularProgressIndicator()
                : const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}
