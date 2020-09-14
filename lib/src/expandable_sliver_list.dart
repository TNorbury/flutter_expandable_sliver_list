import 'package:flutter/material.dart';

import 'expandable_sliver_list_controller.dart';

typedef ExpandableItemBuilder<T> = Widget Function(
    BuildContext context, T item, int index);

/// A [SliverList] that can be used to hide the contents of the list, and expand
/// to show them again.
class ExpandableSliverList<T> extends StatefulWidget {
  /// The initial list of items that'll be displayed in this list. This list
  /// will be copied and used to keep track of the items that the animated list
  /// should be displaying.
  final List<T> initialItems;

  /// Builder function that will be called on every item
  final ExpandableItemBuilder<T> builder;

  /// If set to true, this list will start collapsed, and will need to be
  /// expanded before any of the contents can be shown.
  final bool startCollapsed;

  /// The controller that will operate this animated list
  final ExpandableSliverListController<T> controller;

  /// How long it should take for the entire list to expand or collapse
  final Duration duration;

  /// When the first item is inserted into this list, should it expand?
  final bool expandOnInitialInsertion;

  /// items, build, and controller must be provided
  ExpandableSliverList({
    Key key,
    @required Iterable<T> initialItems,
    @required this.builder,
    @required this.controller,
    this.startCollapsed = false,
    this.duration = const Duration(milliseconds: 500),
    this.expandOnInitialInsertion = false,
  })  : initialItems = List<T>.from(initialItems ?? []),
        super(key: key);

  @override
  _ExpandableSliverListState<T> createState() =>
      _ExpandableSliverListState<T>();
}

class _ExpandableSliverListState<T> extends State<ExpandableSliverList<T>> {
  final GlobalKey<SliverAnimatedListState> _listKey =
      GlobalKey<SliverAnimatedListState>();

  @override
  void initState() {
    super.initState();

    ExpandableSliverListStatus initialStatus = widget.startCollapsed
        ? ExpandableSliverListStatus.collapsed
        : ExpandableSliverListStatus.expanded;

    if (widget.startCollapsed) {
      initialStatus = ExpandableSliverListStatus.collapsed;
    } else {
      initialStatus = ExpandableSliverListStatus.expanded;
    }

    widget.controller.init(
      initialState: initialStatus,
      items: widget.initialItems,
      listKey: _listKey,
      duration: widget.duration,
      builder: widget.builder,
      expandOnInitialInsertion: widget.expandOnInitialInsertion,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverAnimatedList(
      key: _listKey,
      initialItemCount: widget.controller.numItemsDisplayed(),
      itemBuilder: (
        BuildContext context,
        int index,
        Animation<double> animation,
      ) {
        var item = widget.initialItems[index];
        return SizeTransition(
          sizeFactor: animation,
          child: widget.builder(context, item, index),
        );
      },
    );
  }
}
