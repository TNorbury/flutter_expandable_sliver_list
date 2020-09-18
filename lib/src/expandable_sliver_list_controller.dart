import 'dart:async';

import 'package:flutter/material.dart';

import 'expandable_sliver_list.dart';

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

  ExpandableItemBuilder<T> _builder;

  Duration _duration = kDefaultDuration;
  bool _expandOnInitialInsertion;

  /// Controller that'll be used to switch the list between collapsed and
  /// expanded
  ExpandableSliverListController() : super(null);

  /// Initializer to be called by the expandable list this is assigned to
  void init({
    @required ExpandableSliverListStatus initialState,
    @required List<T> items,
    @required GlobalKey<SliverAnimatedListState> listKey,
    @required ExpandableItemBuilder<T> builder,
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

  /// Sets the items in this collection.
  ///
  /// Useful for when the this controller's items are supposed to be mirroring
  /// another collection, but that other collection was changed in a way that
  /// insert/remove couldn't be called.
  void setItems(List<T> items) {
    // If there is a timer of some sort being used right now, either for
    // expanding/collapsing, or when multiple items are being added, we won't
    // set the items, as that could mess up what the timer is trying to
    // accomplish
    if (!(_timer?.isActive ?? false)) {
      _items = List.from(items);

      _numItemsDisplayed =
          value == ExpandableSliverListStatus.collapsed ? 0 : _items.length;

      _calcItemPeriod();
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
    // we'll set our status to expanded
    if (_expandOnInitialInsertion && _items.length == 1) {
      value = ExpandableSliverListStatus.expanded;
    }

    if (!isCollapsed()) {
      _numItemsDisplayed++;
      _listKey.currentState?.insertItem(
        index,
        duration: _duration,
      );
    }
  }

  /// Inserts the given items into the given indices.
  ///
  /// [items] and [indices] should have the same number of items
  ///
  /// All values in [indices] should be valid, which is to say that a given
  /// index shouldn't exceed the the number of items when all but 1 have been
  /// inserted. This method assumes that both lists are ordered in the way that
  /// you want the items to be inserted
  void insertItems(List<T> items, List<int> indices) {
    assert(items.length == indices.length);

    // validates the indices
    int maxNumItems = _items.length + indices.length;
    for (int index in indices) {
      if (index > maxNumItems) {
        throw Exception(
          "Index $index is invalid and can't be inserted into the list",
        );
      }
    }

    // If this is our initial insertion, and we're expanding on that, then we'll
    // put ourselves into the expanded state
    if (_expandOnInitialInsertion && _items.length == 0) {
      value = ExpandableSliverListStatus.expanded;
    }

    _timer?.cancel();

    Duration period = Duration(milliseconds: (250 / items.length).round());

    _timer = Timer.periodic(
      period,
      (timer) {
        if (items.length != 0 && indices.length != 0) {
          T item = items.removeAt(0);
          int index = indices.removeAt(0);

          // Otherwise, we'll insert it into our collection, and if we're not
          // collapsed, also animate it in
          _items.insert(index, item);

          if (!isCollapsed()) {
            _listKey.currentState.insertItem(index, duration: period);
            _numItemsDisplayed++;
          }
        }

        // Once we run out of items to add, we'll stop the timer and recalculate
        // our item period
        else {
          timer.cancel();
          _calcItemPeriod();
        }
      },
    );
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
          child: _builder(context, item, index),
        ),
        duration: _duration,
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
            duration: _itemPeriod,
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
          _numItemsDisplayed -= 1;
          T item = _items[_numItemsDisplayed];

          _listKey.currentState.removeItem(
            _numItemsDisplayed,
            (context, animation) {
              return SizeTransition(
                sizeFactor: animation,
                child: _builder(context, item, _numItemsDisplayed),
              );
            },
            duration: _itemPeriod,
          );
        } else {
          timer.cancel();
        }
      },
    );
  }
}
