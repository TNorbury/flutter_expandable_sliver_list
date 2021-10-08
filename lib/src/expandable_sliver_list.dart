import 'package:flutter/material.dart';

import 'expandable_sliver_list_controller.dart';

/// Builder for creating items in the list
typedef ExpandableItemBuilder<T> = Widget Function(
    BuildContext context, T item, int index);

/// Default duration for expanding/collapsing animation
const Duration kDefaultDuration = Duration(milliseconds: 500);

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
  ///
  /// Please note that use of this is deprecated. Using this will override
  /// whatever value is set in ExpandableSliverListController's initialStatus.
  late final bool startCollapsed;
  late final bool usedDeprecatedArg;

  /// The controller that will operate this animated list
  final ExpandableSliverListController<T> controller;

  /// How long it should take for the entire list to expand or collapse
  final Duration duration;

  /// When the first item is inserted into this list, should it expand?
  final bool expandOnInitialInsertion;

  /// items, build, and controller must be provided
  ExpandableSliverList({
    Key? key,
    required Iterable<T> initialItems,
    required this.builder,
    required this.controller,
    @Deprecated("Use 'initialState' argument in the constructor of ExpandableSliverListController instead. This argument will be removed on Jan 3, 2022. If using the non-deprecated form, make sure to remove this argument as well, as this will overwrite the value set in the controller")
        bool? startCollapsed,
    this.duration = kDefaultDuration,
    this.expandOnInitialInsertion = false,
  })  : initialItems = List<T>.from(initialItems),
        super(key: key) {
    if (startCollapsed != null) {
      this.startCollapsed = startCollapsed;
      usedDeprecatedArg = true;
    } else {
      this.startCollapsed = false;
      usedDeprecatedArg = false;
    }
  }

  @override
  _ExpandableSliverListState<T> createState() =>
      _ExpandableSliverListState<T>();
}

class _ExpandableSliverListState<T> extends State<ExpandableSliverList<T>> {
  @override
  void initState() {
    super.initState();

    ExpandableSliverListStatus? initialStatus;

    if (widget.usedDeprecatedArg) {
      initialStatus = widget.startCollapsed
          ? ExpandableSliverListStatus.collapsed
          : ExpandableSliverListStatus.expanded;

      if (widget.startCollapsed) {
        initialStatus = ExpandableSliverListStatus.collapsed;
      } else {
        initialStatus = ExpandableSliverListStatus.expanded;
      }
    }

    widget.controller.init(
      items: widget.initialItems,
      duration: widget.duration,
      builder: widget.builder,
      initialState: initialStatus,
      expandOnInitialInsertion: widget.expandOnInitialInsertion,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverAnimatedList(
      key: widget.controller.listKey,
      initialItemCount: widget.controller.numItemsDisplayed(),
      itemBuilder: (
        BuildContext context,
        int index,
        Animation<double> animation,
      ) {
        // In the event that the index is out of range for some reason, we'll
        // make a simple container
        if (index >= widget.initialItems.length) {
          return Container();
        }

        // Otherwise, we'll build what we're supposed to
        else {
          var item = widget.initialItems[index];
          return SizeTransition(
            sizeFactor: animation,
            child: widget.builder(context, item, index),
          );
        }
      },
    );
  }
}
