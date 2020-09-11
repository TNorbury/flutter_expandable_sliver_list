import 'dart:async';

import 'package:flutter/material.dart';

/// The status of the expandable list
enum ExpandableSliverListStatus {
  /// The list is expanded. Items are visible.
  expanded,

  /// The list is collapsed. Items aren't visible.
  collapsed,
}

/// Controller that'll be used to switch the list between collapsed and expanded
class ExpandableSliverListController<T>
    extends ValueNotifier<ExpandableSliverListStatus> {
  List<T> _items;

  GlobalKey<SliverAnimatedListState> _listKey;

  Timer _timer;

  /// The number of items that're currently displayed by the list
  int _numItemsDisplayed;

  /// The period between each item being added/removed (visually) from the list
  Duration _itemPeriod;

  Widget Function(BuildContext context, T item) _builder;

  Duration _duration;
  bool _expandOnInitialInsertion;

  /// Controller that'll be used to switch the list between collapsed and
  /// expanded
  ExpandableSliverListController() : super(null);

  /// Initializer to be called by the expandable list this is assigned to
  void init({
    @required ExpandableSliverListStatus initialState,
    @required List<T> items,
    @required GlobalKey<SliverAnimatedListState> listKey,
    @required Widget Function(BuildContext context, T item) builder,
    @required Duration duration,
    bool expandOnInitialInsertion = false,
  }) {
    assert(initialState != null);
    assert(items != null);
    assert(listKey != null);
    assert(builder != null);
    assert(duration != null);

    value = initialState;
    _items = items;
    _listKey = listKey;
    _builder = builder;
    _duration = duration;
    _expandOnInitialInsertion = expandOnInitialInsertion;

    _numItemsDisplayed =
        value == ExpandableSliverListStatus.collapsed ? 0 : _items.length;

    _calcItemPeriod();
  }

  @override
  void dispose() {
    _timer?.cancel();

    super.dispose();
  }

  /// Calculate the animation time for a single item.
  void _calcItemPeriod() {
    if (_items.length != 0) {
      _itemPeriod = Duration(
          microseconds: (_duration.inMicroseconds / _items.length).round());
    }
    //
    else {
      _itemPeriod = _duration;
    }
  }

  /// Collapse the list this controller is connected to
  void collapse() {
    value = ExpandableSliverListStatus.collapsed;

    // If there is a timer going on currently, we'll cancel it
    _timer?.cancel();
    _timer = _collapseTimer();
  }

  /// Expand the list this controller is connected to
  void expand() {
    value = ExpandableSliverListStatus.expanded;

    // If there is a timer going on currently, we'll cancel it
    _timer?.cancel();
    _timer = _expandTimer();
  }

  /// Returns true if the list is currently collapsed. Otherwise false
  bool isCollapsed() {
    return value == ExpandableSliverListStatus.collapsed;
  }

  /// Insert the given item at the given index in the list
  void insertItem(T item, int index) {
    assert(index >= 0 && index <= _items.length);
    _items.insert(index, item);

    _calcItemPeriod();

    // If this is the first item and we're expanding on initial insertion,
    // we'll expand
    if (_expandOnInitialInsertion && _items.length == 1) {
      expand();
    } else if (!isCollapsed()) {
      _numItemsDisplayed++;
      _listKey.currentState?.insertItem(
        index,
        duration: _itemPeriod,
      );
    }
  }

  /// Remove the item at the given index
  void removeItem(int index) {
    assert(index >= 0 && index < _items.length);

    T item = _items.removeAt(index);

    _calcItemPeriod();

    if (!isCollapsed()) {
      _numItemsDisplayed--;
      _listKey.currentState?.removeItem(
        index,
        (context, animation) => SizeTransition(
          sizeFactor: animation,
          child: _builder(context, item),
        ),
        duration: _itemPeriod,
      );
    }
  }

  /// Gets the number of items currently displayed in the list.
  /// This can be different from the number of items in the list.
  int numItemsDisplayed() => _numItemsDisplayed;

  /// Timer for when the list is expanding
  Timer _expandTimer() {
    return Timer.periodic(
      _itemPeriod,
      (timer) {
        if (_numItemsDisplayed < _items.length) {
          _listKey.currentState.insertItem(
            _numItemsDisplayed++,
          );
        }

        if (_numItemsDisplayed >= _items.length) {
          timer.cancel();
        }
      },
    );
  }

  /// Timer for when the list is collapsing
  Timer _collapseTimer() {
    return Timer.periodic(
      _itemPeriod,
      (timer) {
        if (_numItemsDisplayed >= 1) {
          T item = _items[_numItemsDisplayed - 1];

          _listKey.currentState.removeItem(
            --_numItemsDisplayed,
            (context, animation) {
              return SizeTransition(
                sizeFactor: animation,
                child: _builder(context, item),
              );
            },
          );
        } else {
          timer.cancel();
        }
      },
    );
  }
}
