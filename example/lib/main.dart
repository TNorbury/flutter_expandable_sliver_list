import 'package:expandable_sliver_list/expandable_sliver_list.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expandable Sliver List Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Expandable Sliver List Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<int> _nums = [
    0,
    1,
    2,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    14,
    15,
    16,
    17,
    18,
    19,
    20
  ];

  ExpandableSliverListController _controller =
      ExpandableSliverListController();

  void _toggleList() {
    if (_controller.isCollapsed()) {
      _controller.expand();
    } else {
      _controller.collapse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: CustomScrollView(
        slivers: [
          ExpandableSliverList<int>(
            items: _nums,
            controller: _controller,
            // startCollapsed: true,
            duration: const Duration(seconds: 1),
            builder: (context, item) {
              return ListTile(
                title: Text(item.toString()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleList,
        child: Icon(Icons.add),
      ),
    );
  }
}
