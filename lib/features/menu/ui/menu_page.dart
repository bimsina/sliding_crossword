import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_crossword/core/theme/ui/app_logo.dart';
import 'package:sliding_crossword/core/theme/ui/theme_selector.dart';
import 'package:sliding_crossword/core/ui/responsive_builder.dart';
import 'package:sliding_crossword/features/create_puzzle/ui/create_puzzle_button.dart';
import 'package:sliding_crossword/features/menu/models/menu_item.dart';
import 'package:sliding_crossword/features/puzzles_list/state/puzzles_list_state.dart';
import 'package:sliding_crossword/features/puzzles_list/ui/puzzles_list_page.dart';
import 'package:sliding_crossword/features/profile/ui/profile_icon.dart';
import 'package:go_router/go_router.dart';
import 'package:sliding_crossword/features/puzzle/models/puzzle/puzzle.dart';

const _menuItems = [
  MenuItem(title: "Easy", difficulty: PuzzleDifficulty.easy),
  MenuItem(title: "Medium", difficulty: PuzzleDifficulty.medium),
  MenuItem(title: "Hard", difficulty: PuzzleDifficulty.hard),
];

class MenuPage extends StatelessWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ResponsiveLayoutBuilder(
                small: (ctxt, child) => const _MobileAndTabletMenuBuilder(),
                large: (ctxt, child) => const _DesktopMenuBuilder(),
                medium: (ctxt, child) => const _MobileAndTabletMenuBuilder(),
              ),
              const Positioned(right: 8, top: 8, child: ProfileIcon()),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileAndTabletMenuBuilder extends StatelessWidget {
  const _MobileAndTabletMenuBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(
          flex: 2,
          child: Center(child: AppLogo()),
        ),
        Expanded(
          flex: 4,
          child: _MenuItemsWidget(
            onMenuItemTap: (item) {
              context.push('/puzzles-list');
            },
          ),
        ),
        const _BottomRow(),
      ],
    );
  }
}

class _DesktopMenuBuilder extends StatefulWidget {
  const _DesktopMenuBuilder({Key? key}) : super(key: key);

  @override
  State<_DesktopMenuBuilder> createState() => _DesktopMenuBuilderState();
}

class _DesktopMenuBuilderState extends State<_DesktopMenuBuilder> {
  MenuItem? _selectedItem;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          const Expanded(child: AppLogo()),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: _MenuItemsWidget(
                      onMenuItemTap: (item) {
                        setState(() {
                          _selectedItem = item;
                        });
                      },
                    ),
                  ),
                ),
                const _BottomRow(),
              ],
            ),
          ),
          AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOutQuad,
              child: _selectedItem == null
                  ? const SizedBox.shrink()
                  : SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: PuzzlesListPage(
                        onClose: () {
                          setState(() {
                            _selectedItem = null;
                          });
                        },
                      ))),
        ],
      ),
    );
  }
}

class _MenuItemsWidget extends StatefulWidget {
  final Function(MenuItem) onMenuItemTap;
  const _MenuItemsWidget({Key? key, required this.onMenuItemTap})
      : super(key: key);

  @override
  State<_MenuItemsWidget> createState() => _MenuItemsWidgetState();
}

class _MenuItemsWidgetState extends State<_MenuItemsWidget> {
  bool _isCrossWord = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 250),
      child: DefaultTabController(
        length: 2,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TabBar(
                onTap: (int value) {
                  setState(() {
                    _isCrossWord = value == 0;
                  });
                },
                tabs: const [
                  Tab(text: "Crossword"),
                  Tab(text: "Classic"),
                ]),
            const SizedBox(height: 16),
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.builder(
                itemCount: _menuItems.length,
                key: const Key('menu-items'),
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  final item = _menuItems[index];
                  return Card(
                    child: ListTile(
                      onTap: () {
                        Provider.of<PuzzleListState>(context, listen: false)
                            .filter = (Provider.of<PuzzleListState>(context,
                                        listen: false)
                                    .filter ??
                                const PuzzlesListFilter())
                            .copyWith(difficulty: item.difficulty);
                        if (_isCrossWord) {
                          widget.onMenuItemTap(item);
                        } else {
                          context.push('/puzzle',
                              extra:
                                  Puzzle(gridSize: item.difficulty.index + 3));
                        }
                      },
                      title: Text(item.title, textAlign: TextAlign.center),
                      subtitle: Text(
                          "${item.difficulty.index + 3}x${item.difficulty.index + 3}",
                          textAlign: TextAlign.center),
                    ),
                  );
                },
              ),
            ),
            AnimatedScale(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInToLinear,
              scale: _isCrossWord ? 0 : 1,
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  child: ListTile(
                    title:
                        const Text("Custom Size", textAlign: TextAlign.center),
                    subtitle: const Text("NxN", textAlign: TextAlign.center),
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return const _CustomSizeSelectorDialog();
                          });
                    },
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _BottomRow extends StatelessWidget {
  const _BottomRow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
              onPressed: () {}, icon: const Icon(Icons.settings_rounded)),
          const CreatePuzzleButton(),
          const ThemeSelectorButton()
        ],
      ),
    );
  }
}

class _CustomSizeSelectorDialog extends StatefulWidget {
  const _CustomSizeSelectorDialog({Key? key}) : super(key: key);

  @override
  __CustomSizeSelectorDialogState createState() =>
      __CustomSizeSelectorDialogState();
}

class __CustomSizeSelectorDialogState extends State<_CustomSizeSelectorDialog> {
  late List<int> _gridSizes;
  late int _selectedGrid;

  @override
  void initState() {
    _gridSizes = List.generate(10, (i) => i + 5);
    _selectedGrid = _gridSizes.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsPadding: const EdgeInsets.only(bottom: 8.0),
      title: const Text("Select puzzle size"),
      content: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Selected size : ", style: TextStyle(fontSize: 18)),
              DropdownButton<int>(
                value: _selectedGrid,
                underline: Container(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedGrid = value;
                  });
                },
                items: _gridSizes
                    .map((i) =>
                        DropdownMenuItem(value: i, child: Text("${i}x$i")))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        FloatingActionButton.extended(
          onPressed: () {
            context.push('/puzzle', extra: Puzzle(gridSize: _selectedGrid));
          },
          icon: const Icon(Icons.check_circle_outline_rounded),
          label: const Text("Start"),
        )
      ],
    );
  }
}
