import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:expandable_sliver_list/expandable_sliver_list.dart';

void main() {
  test(
    "expandable sliver list controller works",
    () {
      ExpandableSliverListController expandableSliverListController =
          ExpandableSliverListController();

      // start off expanded
      expandableSliverListController.init(ExpandableSliverListStatus.expanded);
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

  final ExpandableSliverListController _expandableSliverListController =
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
            items: _items,
            startCollapsed: widget.startCollapsed,
            controller: _expandableSliverListController,
            duration: const Duration(seconds: 1),
            builder: (context, item) {
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
