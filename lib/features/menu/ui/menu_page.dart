import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sliding_crossword/core/state/puzzle_list_state.dart';
import 'package:sliding_crossword/core/theme/state/theme_notifier.dart';
import 'package:sliding_crossword/core/theme/ui/theme_selector.dart';
import 'package:sliding_crossword/core/ui/responsive_builder.dart';
import 'package:sliding_crossword/features/puzzle/models/puzzle/puzzle.dart';
import 'package:sliding_crossword/features/puzzle/ui/puzzle_page.dart';

class MenuItem extends Equatable {
  final String title;
  final int gridSize;
  final bool? isNew;

  const MenuItem(
      {required this.title, required this.gridSize, this.isNew = false});

  @override
  List<Object?> get props => [title, gridSize, isNew];
}

const _menuItems = [
  MenuItem(title: "Easy", gridSize: 3),
  MenuItem(title: "Medium", gridSize: 4),
  MenuItem(title: "Hard", gridSize: 5),
];

class MenuPage extends StatelessWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ResponsiveLayoutBuilder(
            small: (ctxt, child) => const _MobileAndTabletMenuBuilder(),
            large: (ctxt, child) => const _DesktopMenuBuilder(),
            medium: (ctxt, child) => const _MobileAndTabletMenuBuilder(),
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _themeState = Provider.of<ThemeNotifier>(context);
    final color = _themeState.selectedTheme.accentColor;
    return ResponsiveLayoutBuilder(
        small: (_, __) => _logo(100, color),
        medium: (_, __) => _logo(150, color),
        large: (_, __) => _logo(250, color));
  }

  Widget _logo(double height, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          "assets/images/logo.svg",
          height: height,
          color: color,
        ),
        const SizedBox(height: 10),
        Wrap(
          children: [
            Text(
              "Sliding ",
              style: TextStyle(fontSize: height * 0.3, color: color),
            ),
            Text(
              "Crossword",
              style: TextStyle(
                  fontSize: height * 0.3, fontWeight: FontWeight.bold),
            ),
          ],
        )
      ],
    );
  }
}

class _MobileAndTabletMenuBuilder extends StatelessWidget {
  const _MobileAndTabletMenuBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _Title(),
              const SizedBox(height: 40),
              _MenuItemsWidget(
                onMenuItemTap: (item) {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                    return _MenuItemPuzzleSelector(item: item);
                  }));
                },
              ),
            ],
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
          const Expanded(child: _Title()),
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
                      child: _MenuItemPuzzleSelector(item: _selectedItem!))),
        ],
      ),
    );
  }
}

class _MenuItemsWidget extends StatefulWidget {
  final Function onMenuItemTap;
  const _MenuItemsWidget({Key? key, required this.onMenuItemTap})
      : super(key: key);

  @override
  State<_MenuItemsWidget> createState() => _MenuItemsWidgetState();
}

class _MenuItemsWidgetState extends State<_MenuItemsWidget> {
  final ScrollController _scrollController = ScrollController();
  bool _isCrossWord = true;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView.builder(
                  itemCount: _menuItems.length,
                  key: const Key('menu-items'),
                  shrinkWrap: true,
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    final item = _menuItems[index];
                    return Card(
                      elevation: 0,
                      child: ListTile(
                        title: Text(item.title, textAlign: TextAlign.center),
                        subtitle: Text("${item.gridSize}x${item.gridSize}",
                            textAlign: TextAlign.center),
                        onTap: () {
                          if (_isCrossWord) {
                            widget.onMenuItemTap(item);
                          } else {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => PuzzlePage(
                                      puzzle: Puzzle(gridSize: item.gridSize),
                                    )));
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              AnimatedScale(
                scale: _isCrossWord ? 0 : 1,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOutQuad,
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    elevation: 0,
                    child: ListTile(
                      title: const Text("Custom size",
                          textAlign: TextAlign.center),
                      subtitle: const Text("NxN", textAlign: TextAlign.center),
                      onTap: () {},
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItemPuzzleSelector extends StatelessWidget {
  final MenuItem item;
  final bool showAppBar;

  _MenuItemPuzzleSelector(
      {Key? key, required this.item, this.showAppBar = true})
      : super(key: key);

  final ScrollController _scrollController = ScrollController();

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
          child: Container(
            constraints: const BoxConstraints(maxWidth: 250),
            child: Center(
              child: _puzzles.isEmpty
                  ? const Text("No Puzzles Found")
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.builder(
                        shrinkWrap: true,
                        controller: _scrollController,
                        itemCount: _puzzles.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            elevation: 0,
                            child: ListTile(
                              title: Text(
                                _puzzles[index].title,
                                textAlign: TextAlign.center,
                              ),
                              trailing:
                                  const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => PuzzlePage(
                                          puzzle: _puzzles[index],
                                        )));
                              },
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ),
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
          FloatingActionButton.extended(
            heroTag: 'create_puzzle',
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text("Create your puzzle"),
          ),
          const ThemeSelectorButton()
        ],
      ),
    );
  }
}
