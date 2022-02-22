import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:go_router/go_router.dart';
import 'package:sliding_crossword/features/puzzle/models/grid.dart';
import 'package:sliding_crossword/features/puzzle/models/puzzle/puzzle.dart';
import 'package:sliding_crossword/features/puzzle/models/tile.dart';
import 'package:sliding_crossword/features/puzzle/ui/game_end_page.dart';

enum PuzzlePageState { playing, paused }

class PuzzleState extends ChangeNotifier {
  late List<Tile> _tiles;

  late List<Grid> _grids;

  final List<Grid> _adjacentGrids = [];
  late Tile _emptyTile;

  int _gridSize = 3;
  int get gridSize => _gridSize;

  int _moves = 0;
  int get moves => _moves;

  List<Tile> get tiles => _tiles;
  List<Grid> get grids => _grids;
  List<Grid> get adjacentGrids => _adjacentGrids;
  Tile get emptyTile => _emptyTile;

  late List<String> _acrossWords;
  late List<String> _downWords;

  final List<int> _correctRows = [];
  final List<int> _correctColumns = [];

  List<int> get correctRows => _correctRows;
  List<int> get correctColumns => _correctColumns;

  final Puzzle _puzzle;
  Puzzle get puzzle => _puzzle;

  List<Question> _availablePrompts = [];
  List<Question> get availablePrompts => _availablePrompts;

  final PageController _promptController = PageController();
  PageController get promptController => _promptController;

  Question? _selectedPrompt;
  Question? get selectedPrompt => _selectedPrompt;
  set selectedPrompt(Question? value) {
    _selectedPrompt = value;
    notifyListeners();
  }

  changePrompt(int index) {
    _selectedPrompt = _availablePrompts[index];
    notifyListeners();
  }

  PuzzlePageState _state = PuzzlePageState.playing;
  PuzzlePageState get state => _state;

  set state(PuzzlePageState state) {
    _state = state;
    if (state == PuzzlePageState.playing) {
      resumeTimer();
    } else {
      pauseTimer();
    }
    notifyListeners();
  }

  jumpToPrompt(int value) {
    _promptController.jumpToPage(value);
  }

  bool _showHints = false;
  bool get showHints => _showHints;
  set showHints(bool value) {
    _showHints = value;
    notifyListeners();
  }

  late Timer _timer;
  Duration _timeElapsed = const Duration(seconds: 0);
  Duration get timeElapsed => _timeElapsed;

  final BuildContext _context;

  PuzzleState(this._puzzle, this._context) {
    _gridSize = _puzzle.gridSize;
    _initTimer();
    _generateTiles();
  }

  @override
  void dispose() {
    _timer.cancel();
    _promptController.dispose();
    super.dispose();
  }

  _initTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _timeElapsed += const Duration(seconds: 1);
      if (_puzzle is CrosswordPuzzle) {
        final _maxSeconds = (_puzzle as CrosswordPuzzle).maxSecondsAvailable;
        if (_maxSeconds != null) {
          if (_timeElapsed.inSeconds >= _maxSeconds) {
            _showGameEndDialog(
                GameEndPagePayload(this, GameEndPageState.lossViaTimeout));
          }
        }
      }
      notifyListeners();
    });
  }

  pauseTimer() {
    _timer.cancel();
  }

  resumeTimer() {
    _initTimer();
  }

  _generateTiles() {
    _grids = List.generate(
        _gridSize * _gridSize,
        (index) => Grid(
              x: _getColumn(index),
              y: _getRow(index),
            ));

    final _length = _gridSize * _gridSize;

    if (_puzzle is CrosswordPuzzle) {
      final _crossword = _puzzle as CrosswordPuzzle;

      List<String> _initialAcrossWords = [];
      List<String> _initialDownWords = [];

      for (int i = 0; i < _gridSize; i++) {
        String _singleAcross = "";
        String _singleDown = "";

        for (int j = 0; j < _gridSize; j++) {
          final _acrossValue = (j + 1) + (i * _gridSize);
          _singleAcross += _acrossValue == _gridSize * _gridSize
              ? " "
              : _crossword.tiles[_acrossValue - 1];
          final _downvalue = (i + 1) + (j * _gridSize);
          _singleDown += _downvalue == _gridSize * _gridSize
              ? " "
              : _crossword.tiles[_downvalue - 1];
        }
        _initialAcrossWords.add(_singleAcross);
        _initialDownWords.add(_singleDown);
      }

      _acrossWords = _initialAcrossWords;
      _downWords = _initialDownWords;

      _tiles = List.generate(_length, (index) => index)
          .map((index) => Tile(
              canInteract: true,
              value: index == _length - 1 ? null : _crossword.tiles[index],
              id: index.toString()))
          .toList();
      _availablePrompts = [..._crossword.across, ..._crossword.down]
          .where((element) => element.prompt != '-')
          .toList();
      if (_availablePrompts.isNotEmpty) {
        _selectedPrompt = _availablePrompts.first;
      }
    } else {
      _tiles = List.generate(
          _length,
          (index) => Tile(
                value: index == _length - 1 ? null : '${index + 1}',
                id: index.toString(),
                canInteract: true,
              ));

      List<String> _initialAcrossWords = [];
      List<String> _initialDownWords = [];

      for (int i = 0; i < _gridSize; i++) {
        String _singleAcross = "";
        String _singleDown = "";

        for (int j = 0; j < _gridSize; j++) {
          final _acrossValue = (j + 1) + (i * _gridSize);
          _singleAcross +=
              _acrossValue == _gridSize * _gridSize ? " " : '$_acrossValue';
          final _downvalue = (i + 1) + (j * _gridSize);
          _singleDown +=
              _downvalue == _gridSize * _gridSize ? " " : '$_downvalue';
        }
        _initialAcrossWords.add(_singleAcross);
        _initialDownWords.add(_singleDown);
      }

      _acrossWords = _initialAcrossWords;
      _downWords = _initialDownWords;
    }

    _findAdjacentTiles(notify: false);
    _shuffle();
  }

  _shuffle() async {
    final _moves = _gridSize * _gridSize * gridSize;

    for (int i = 0; i < _moves; i++) {
      final _randomAdjacent =
          _adjacentGrids[Random().nextInt(_adjacentGrids.length)];
      final _tileToMoveIndex = _grids.indexOf(_randomAdjacent);
      moveTile(_tileToMoveIndex, notify: false);
    }
    notifyListeners();
  }

  int _getRow(index) {
    return index ~/ _gridSize;
  }

  int _getColumn(index) {
    return index % _gridSize;
  }

  _findAdjacentTiles({bool notify = true}) {
    final _indexOfNull = _tiles.indexWhere((tile) => tile.value == null);
    if (_indexOfNull == -1) return;

    _emptyTile = _tiles[_indexOfNull];
    _adjacentGrids.clear();

    for (int _index = 0; _index < _tiles.length; _index++) {
      bool _isAdjacent =
          (_index - 1 == _indexOfNull && (_index % _gridSize != 0)) ||
              (_index + 1 == _indexOfNull && (_indexOfNull % _gridSize != 0)) ||
              (_index + _gridSize == _indexOfNull) ||
              ((_index - _gridSize) == _indexOfNull);
      if (_isAdjacent) {
        _adjacentGrids.add(_grids[_index]);
      }
    }

    if (notify) {
      notifyListeners();
      _findCorrectWordsBuilt();
    }
  }

  _findCorrectWordsBuilt() async {
    _correctColumns.clear();
    _correctRows.clear();

    for (int i = 0; i < _gridSize; i++) {
      final _gridsInColumn = _grids.where((element) => element.x == i).toList();
      String _columnString = "";
      for (final _singleGrid in _gridsInColumn) {
        final _index = _grids.indexOf(_singleGrid);
        _columnString += _tiles[_index].value ?? " ";
      }

      if (_downWords[i] == _columnString) {
        _correctColumns.add(i);
      }
    }

    for (int i = 0; i < _gridSize; i++) {
      final _gridsInRow = _grids.where((element) => element.y == i).toList();
      String _rowString = "";
      for (final _singleGrid in _gridsInRow) {
        final _index = _grids.indexOf(_singleGrid);
        _rowString += _tiles[_index].value ?? " ";
      }

      if (_acrossWords[i] == _rowString) {
        _correctRows.add(i);
      }
    }

    if (_correctColumns.length == _gridSize &&
        _correctRows.length == _gridSize) {
      await Future.delayed(const Duration(milliseconds: 300));
      _showGameEndDialog(GameEndPagePayload(this, GameEndPageState.won));
    }
    notifyListeners();
  }

  _showGameEndDialog(GameEndPagePayload payload) {
    pauseTimer();
    GoRouter.of(_context).pop();
    GoRouter.of(_context).push('/game-end', extra: payload);
  }

  void moveTile(int index, {bool notify = true}) {
    if (!_tiles[index].canInteract) return;

    final _grid = grids[index];
    final _isAdjacent = adjacentGrids.contains(_grid);

    if (!_isAdjacent) {
      final _emptyGrid = _grids[_tiles.indexOf(_emptyTile)];
      final _isInSameColumn = _grid.x == _emptyGrid.x;
      final _isInSameRow = _grid.y == _emptyGrid.y;

      List<Tile> _tilesToMove = [];
      if (_isInSameColumn) {
        final bool _moveDown = _grid.y < _emptyGrid.y;

        for (int _index = _grid.y;
            _moveDown ? _index < _emptyGrid.y : _index > _emptyGrid.y;
            _moveDown ? _index++ : _index--) {
          _tilesToMove.add(_tiles[_grids.indexOf(Grid(x: _grid.x, y: _index))]);
        }
      }
      if (_isInSameRow) {
        final bool _moveRight = _grid.x < _emptyGrid.x;

        for (int _index = _grid.x;
            _moveRight ? _index < _emptyGrid.x : _index > _emptyGrid.x;
            _moveRight ? _index++ : _index--) {
          _tilesToMove.add(_tiles[_grids.indexOf(Grid(x: _index, y: _grid.y))]);
        }
      }
      _tilesToMove = _tilesToMove.reversed.toList();
      if (_tilesToMove.indexWhere((element) => element.canInteract != true) !=
          -1) return;

      for (final tile in _tilesToMove) {
        final _isLast = _tilesToMove.indexOf(tile) == _tilesToMove.length - 1;
        _moveAdjacent(_tiles.indexOf(tile), notify, increaseMoves: _isLast);
      }
      return;
    }

    _moveAdjacent(index, notify);
  }

  void _moveAdjacent(int index, bool notify, {bool increaseMoves = true}) {
    if (!_tiles[index].canInteract) return;
    _tiles.swap(_tiles.indexOf(_emptyTile), index);
    _findAdjacentTiles(notify: notify);
    if (notify) {
      if (increaseMoves) _moves += 1;
      if (_puzzle is CrosswordPuzzle) {
        final _maxMoves = (_puzzle as CrosswordPuzzle).maxMovesAvailable;
        if (_maxMoves != null) {
          if (_moves >= _maxMoves) {
            _showGameEndDialog(
                GameEndPagePayload(this, GameEndPageState.lossViaNoMoreMoves));
          }
        }
      }
      notifyListeners();
    }
  }
}
