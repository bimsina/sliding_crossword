import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_crossword/features/puzzle/models/puzzle/puzzle.dart';
import 'package:sliding_crossword/features/puzzle/state/puzzle_state.dart';

class PromptSelector extends StatelessWidget {
  const PromptSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _puzzleState = Provider.of<PuzzleState>(context);

    if (_puzzleState.puzzle is! CrosswordPuzzle) {
      return const SizedBox();
    }

    return _PromptSelectorPresenter(
      key: const Key('prompt-selector'),
      prompts: _puzzleState.availablePrompts,
      controller: _puzzleState.promptController,
      onPromptChanged: _puzzleState.jumpToPrompt,
      onPageChanged: (page) {
        _puzzleState.changePrompt(page);
      },
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
    final _puzzleState = Provider.of<PuzzleState>(context);
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
                  physics: const BouncingScrollPhysics(),
                  controller: controller,
                  itemCount: prompts.length,
                  onPageChanged: (val) {
                    onPageChanged(val);
                  },
                  itemBuilder: (context, index) {
                    String _subtitle = "";

                    final _inAcrossIndex =
                        (_puzzleState.puzzle as CrosswordPuzzle)
                            .across
                            .indexWhere((element) =>
                                element.id == _puzzleState.selectedPrompt?.id);

                    final _inDownIndex =
                        (_puzzleState.puzzle as CrosswordPuzzle)
                            .down
                            .indexWhere((element) =>
                                element.id == _puzzleState.selectedPrompt?.id);

                    if (_inAcrossIndex != -1) {
                      _subtitle = "${_inAcrossIndex + 1} Across";
                    } else if (_inDownIndex != -1) {
                      _subtitle = "${_inDownIndex + 1} Down";
                    }

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          prompts[index].prompt,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 4),
                        if (_subtitle != "")
                          Text(
                            _subtitle,
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                      ],
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
