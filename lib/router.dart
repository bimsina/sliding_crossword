library router;

import 'package:go_router/go_router.dart';
import 'package:sliding_crossword/features/create_puzzle/ui/create_puzzle_page.dart';
import 'package:sliding_crossword/features/menu/models/menu_item.dart';
import 'package:sliding_crossword/features/menu/ui/menu_page.dart';
import 'package:sliding_crossword/features/page_not_found/page_not_found.dart';
import 'package:sliding_crossword/features/profile/ui/profile_page.dart';
import 'package:sliding_crossword/features/puzzle/ui/puzzle_page.dart';

import 'features/menu/ui/puzzles_list_selector.dart';
import 'features/puzzle/models/puzzle/puzzle.dart';

final router = GoRouter(
  errorBuilder: (context, state) => const PageNotFound(),
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MenuPage(),
    ),
    GoRoute(
      path: '/puzzles-list',
      builder: (context, state) {
        if (state.extra is MenuItem) {
          final item = state.extra as MenuItem;
          return PuzzlesListSelectorPage(item: item);
        } else {
          return const MenuPage();
        }
      },
    ),
    GoRoute(
      path: '/create-puzzle',
      builder: (context, state) => const CreatePuzzlePage(),
    ),
    GoRoute(
      path: '/puzzle',
      builder: (context, state) {
        if (state.extra is Puzzle) {
          final item = state.extra as Puzzle;
          return PuzzlePage(puzzle: item);
        } else {
          return const MenuPage();
        }
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfilePage(),
    ),
  ],
);