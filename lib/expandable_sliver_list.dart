library expandable_sliver_list;

import 'dart:async';

import 'package:flutter/material.dart';

/// The status of the expandable list
enum ExpandableSliverListStatus {
  /// The list is expanded. Items are visible.
  expanded,

  /// The list is collapsed. Items aren't visible.
  collapsed,
}

/// A [SliverList] that can be used to hide the contents of the list, and expand
/// to show them again.
class ExpandableSliverList<T> extends StatefulWidget {
  /// The items that'll be displayed in this list
  final List<T> items;

  /// Builder function that will be called on every item
  final Widget Function(BuildContext context, T item) builder;

  /// If set to true, this list will start collapsed, and will need to be
  /// expanded before any of the contents can be shown.
  final bool startCollapsed;

  /// The controller that will operate this animated list
  final ExpandableSliverListController controller;

  /// How long it should take for the entire list to expand or collapse
  final Duration duration;

  /// items, build, and controller must be provided
  ExpandableSliverList({
    Key key,
    @required this.items,
    @required this.builder,
    @required this.controller,
    this.startCollapsed = false,
    this.duration = const Duration(milliseconds: 500),
  }) : super(key: key);

  @override
  _ExpandableSliverListState<T> createState() =>
      _ExpandableSliverListState<T>();
}

class _ExpandableSliverListState<T> extends State<ExpandableSliverList<T>> {
  final GlobalKey<SliverAnimatedListState> _listKey =
      GlobalKey<SliverAnimatedListState>();

  Timer _timer;
  int _numItemsInList;

  /// The period between each item being added/removed (visually) from the list
  Duration _itemPeriod;

  @override
  void initState() {
    super.initState();

    if (widget.items.length != 0) {
      _itemPeriod = Duration(
          microseconds:
              (widget.duration.inMicroseconds / widget.items.length).round());
    }
    //
    else {
      _itemPeriod = widget.duration;
    }

    // If we're starting collapsed, the initial item count will be 0
    if (widget.startCollapsed) {
      _numItemsInList = 0;

      widget.controller.init(ExpandableSliverListStatus.collapsed);
    }

    // Otherwise, it'll be equal to the number of items in the list
    else {
      _numItemsInList = widget.items.length;

      widget.controller.init(ExpandableSliverListStatus.expanded);
    }

    widget.controller.addListener(() {
      var currentStatus = widget.controller.value;

      // If there is a timer going on currently, we'll cancel it
      _timer?.cancel();

      switch (currentStatus) {
        // The list has been collapsed, so start removing items
        case ExpandableSliverListStatus.collapsed:
          {
            _timer = _collapseTimer();
            break;
          }

        // The list has been expanded, so start adding items back in
        case ExpandableSliverListStatus.expanded:
          {
            _timer = _expandTimer();
            break;
          }
      }
    });
  }

  @override
  void dispose() {
    // Cancel the timer if it's going.
    _timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverAnimatedList(
      key: _listKey,
      initialItemCount: _numItemsInList,
      itemBuilder: (
        BuildContext context,
        int index,
        Animation<double> animation,
      ) {
        var item = widget.items[index];
        return SizeTransition(
          sizeFactor: animation,
          child: widget.builder(context, item),
        );
      },
    );
  }

  /// Timer for when the list is expanding
  Timer _expandTimer() {
    return Timer.periodic(
      _itemPeriod,
      (timer) {
        if (_numItemsInList < widget.items.length) {
          _listKey.currentState.insertItem(
            _numItemsInList++,
          );
        }

        if (_numItemsInList >= widget.items.length) {
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
        if (_numItemsInList >= 1) {
          T item = widget.items[_numItemsInList - 1];

          _listKey.currentState.removeItem(
            --_numItemsInList,
            (context, animation) {
              return SizeTransition(
                sizeFactor: animation,
                child: widget.builder(context, item),
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

/// Controller that'll be used to switch the list between collapsed and expanded
class ExpandableSliverListController
    extends ValueNotifier<ExpandableSliverListStatus> {
  /// Controller that'll be used to switch the list between collapsed and
  /// expanded
  ExpandableSliverListController() : super(null);

  // ignore: use_setters_to_change_properties
  /// Initializer to be called by the expandable list this is assigned to
  void init(ExpandableSliverListStatus initialState) {
    value = initialState;
  }

  /// Collapse the list this controller is connected to
  void collapse() {
    value = ExpandableSliverListStatus.collapsed;
  }

  /// Expand the list this controller is connected to
  void expand() {
    value = ExpandableSliverListStatus.expanded;
  }

  /// Returns true if the list is currently collapse. Otherwise false
  bool isCollapsed() {
    return value == ExpandableSliverListStatus.collapsed;
  }
}
