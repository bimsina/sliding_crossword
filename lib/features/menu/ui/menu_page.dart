import 'package:flutter/material.dart';
import 'package:sliding_crossword/core/theme/ui/app_logo.dart';
import 'package:sliding_crossword/core/theme/ui/theme_selector.dart';
import 'package:sliding_crossword/core/ui/responsive_builder.dart';
import 'package:sliding_crossword/features/create_puzzle/ui/create_puzzle_button.dart';
import 'package:sliding_crossword/features/menu/models/menu_item.dart';
import 'package:sliding_crossword/features/menu/ui/puzzles_list_selector.dart';
import 'package:sliding_crossword/features/profile/ui/profile_icon.dart';
import 'package:go_router/go_router.dart';
import 'package:sliding_crossword/features/puzzle/models/puzzle/puzzle.dart';

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
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppLogo(),
              const SizedBox(height: 40),
              _MenuItemsWidget(
                onMenuItemTap: (item) {
                  context.push('/puzzles-list', extra: item);
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
                      child: PuzzlesListSelectorPage(item: _selectedItem!))),
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
                            context.push('/puzzle',
                                extra: Puzzle(gridSize: item.gridSize));
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
