// ignore_for_file: lines_longer_than_80_chars
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:expandable_sliver_list/expandable_sliver_list.dart';

void main() {
  testWidgets(
    "sliver list will expand and collapse, when not starting collapsed",
    (WidgetTester tester) async {
      await tester.pumpWidget(MyApp(
        startCollapsed: false,
      ));

      // There should be 4 items
      expect(find.byType(ListTile), findsNWidgets(4));

      // Press the button and wait for it to collapse
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // There should be nothing
      expect(find.byType(ListTile), findsNothing);

      // Press the button yet again, and wait for it to expand
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // There should be 4 items
      expect(find.byType(ListTile), findsNWidgets(4));
    },
  );

  testWidgets(
    "sliver list will expand and collapse, when starting collapsed",
    (WidgetTester tester) async {
      await tester.pumpWidget(MyApp(
        startCollapsed: true,
      ));

      // There should be nothing
      expect(find.byType(ListTile), findsNothing);

      // Press the button and wait for it to expand
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // There should be 4 items
      expect(find.byType(ListTile), findsNWidgets(4));

      // Press the button yet again, and wait for it to collapse
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // There should be nothing
      expect(find.byType(ListTile), findsNothing);
    },
  );

  testWidgets(
    "items can be added and removed to the list",
    (WidgetTester tester) async {
      final ExpandableSliverListController<int> controller =
          ExpandableSliverListController();

      List<int> _items = [];
      int counter = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                ExpandableSliverList<int>(
                  initialItems: _items,
                  controller: controller,
                  duration: const Duration(seconds: 1),
                  builder: (context, item, index) {
                    return ListTile(
                      title: Text(item.toString()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );

      // Add a few items
      controller.insertItem(counter, counter);
      counter++;
      controller.insertItem(counter, counter);
      counter++;
      controller.insertItem(counter, counter);
      counter++;
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsNWidgets(3));

      // remove one of the items
      controller.removeItem(counter - 1);
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsNWidgets(2));
    },
  );

  testWidgets(
    "items added or removed when the list is collapsed will be displayed when it's expanded again",
    (WidgetTester tester) async {
      final ExpandableSliverListController<int> controller =
          ExpandableSliverListController();

      List<int> _items = [];
      int counter = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                ExpandableSliverList<int>(
                  initialItems: _items,
                  controller: controller,
                  startCollapsed: true,
                  builder: (context, item, index) {
                    return ListTile(
                      title: Text(item.toString()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );

      // add some items and expand, they should be present
      controller.insertItem(counter, counter);
      counter++;
      await tester.pumpAndSettle();
      controller.insertItem(counter, counter);
      counter++;
      await tester.pumpAndSettle();

      controller.expand();
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      expect(find.byType(ListTile), findsNWidgets(2));

      controller.insertItem(counter, counter);
      counter++;

      // collapse, and remove an item, expand again, it should be present
      controller.collapse();
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      controller.removeItem(1);

      controller.expand();
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      expect(find.byType(ListTile), findsNWidgets(2));
      expect(find.text("0"), findsOneWidget);
      expect(find.text("2"), findsOneWidget);
    },
  );

  testWidgets(
    "expand on initial insertion",
    (WidgetTester tester) async {
      final ExpandableSliverListController<int> controller =
          ExpandableSliverListController();

      List<int> _items = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                ExpandableSliverList<int>(
                  initialItems: _items,
                  controller: controller,
                  duration: const Duration(seconds: 1),
                  startCollapsed: true,
                  expandOnInitialInsertion: true,
                  builder: (context, item, index) {
                    return ListTile(
                      title: Text(item.toString()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );

      controller.insertItem(0, 0);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.byType(ListTile), findsNWidgets(1));
    },
  );

  testWidgets(
    "insertItems allows multiple items to be added",
    (WidgetTester tester) async {
      final ExpandableSliverListController<int> controller =
          ExpandableSliverListController();

      List<int> _items = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                ExpandableSliverList<int>(
                  initialItems: _items,
                  controller: controller,
                  duration: const Duration(milliseconds: 250),
                  builder: (context, item, index) {
                    return ListTile(
                      title: Text(item.toString()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );

      controller.insertItems([1, 2, 3], [0, 1, 2]);
      await tester.pumpAndSettle(Duration(milliseconds: 251));
      expect(find.byType(ListTile), findsNWidgets(3));
    },
  );

  testWidgets(
    "using insertItems with an invalid index will throw an exception",
    (WidgetTester tester) async {
      final ExpandableSliverListController<int> controller =
          ExpandableSliverListController();

      List<int> _items = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                ExpandableSliverList<int>(
                  initialItems: _items,
                  controller: controller,
                  duration: const Duration(milliseconds: 250),
                  builder: (context, item, index) {
                    return ListTile(
                      title: Text(item.toString()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );

      expect(
          () => controller.insertItems([1, 2, 3], [0, 4, 1]), throwsException);
    },
  );

  group("controller tests", () {
    test(
      "expandable sliver list controller works",
      () {
        ExpandableSliverListController expandableSliverListController =
            ExpandableSliverListController();

        final GlobalKey<SliverAnimatedListState> _listKey =
            GlobalKey<SliverAnimatedListState>();
        // start off expanded
        expandableSliverListController.init(
          initialState: ExpandableSliverListStatus.expanded,
          items: [],
          listKey: _listKey,
          builder: (BuildContext context, item, index) {
            return Container();
          },
          duration: const Duration(milliseconds: 250),
        );
        expect(expandableSliverListController.isCollapsed(), false);

        // collapse
        expandableSliverListController.collapse();
        expect(expandableSliverListController.isCollapsed(), true);

        // expand
        expandableSliverListController.expand();
        expect(expandableSliverListController.isCollapsed(), false);

        // listener works
        bool listenerCalled = false;
        expandableSliverListController.addListener(() {
          listenerCalled = true;
        });

        // already expanded, won't call listener
        expandableSliverListController.expand();
        expect(listenerCalled, false);

        // collapsing will call listener
        expandableSliverListController.collapse();
        expect(listenerCalled, true);
      },
    );

    test(
      "Verify asserts work on controller",
      () {
        final ExpandableSliverListController<int> controller =
            ExpandableSliverListController();

        // Throw an exception when the following aren't passed:
        // initial state
        expect(() => controller.init(), throwsAssertionError);

        // items
        expect(
            () => controller.init(
                initialState: ExpandableSliverListStatus.collapsed),
            throwsAssertionError);

        // listKey
        expect(
            () => controller.init(
                initialState: ExpandableSliverListStatus.collapsed, items: []),
            throwsAssertionError);

        // builder
        GlobalKey<SliverAnimatedListState> listKey =
            GlobalKey<SliverAnimatedListState>();
        expect(
            () => controller.init(
                initialState: ExpandableSliverListStatus.collapsed,
                items: [],
                listKey: listKey),
            throwsAssertionError);

        //duration
        expect(
            () => controller.init(
                  initialState: ExpandableSliverListStatus.collapsed,
                  items: [],
                  listKey: listKey,
                  builder: (context, item, index) => Container(),
                ),
            throwsAssertionError);
      },
    );
    test(
      "disposing the controller works and prevents new listeners from being added",
      () {
        final ExpandableSliverListController<int> controller =
            ExpandableSliverListController();

        controller.dispose();
        expect(() => controller.addListener(() {}), throwsFlutterError);
      },
    );
    test(
      "set items in controller",
      () {
        ExpandableSliverListController<int> controller =
            ExpandableSliverListController<int>();
        controller.value = ExpandableSliverListStatus.expanded;

        // Hasn't been initialized yet.
        expect(controller.numItemsDisplayed(), null);

        // when expanded, setting a list of 3 will display 3 items
        controller.setItems([1, 2, 3]);
        expect(controller.numItemsDisplayed(), 3);

        controller.value = ExpandableSliverListStatus.collapsed;

        // when collapsed, setting any size list will still display 0 items
        controller.setItems([1, 2, 3, 4, 5, 6]);
        expect(controller.numItemsDisplayed(), 0);
      },
    );
  });
}

class MyApp extends StatelessWidget {
  final bool startCollapsed;

  MyApp({@required this.startCollapsed});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(
        startCollapsed: startCollapsed,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final bool startCollapsed;
  MyHomePage({@required this.startCollapsed});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> _items = ["Hello", "This", "List", "Expands"];

  final ExpandableSliverListController<String> _expandableSliverListController =
      ExpandableSliverListController();

  void _toggleList() {
    if (_expandableSliverListController.isCollapsed()) {
      _expandableSliverListController.expand();
    } else {
      _expandableSliverListController.collapse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          ExpandableSliverList<String>(
            initialItems: _items,
            startCollapsed: widget.startCollapsed,
            controller: _expandableSliverListController,
            duration: const Duration(seconds: 1),
            builder: (context, item, index) {
              return ListTile(
                title: Text(item),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: Key("FAB"),
        onPressed: _toggleList,
        child: Icon(Icons.add),
      ),
    );
  }
}
