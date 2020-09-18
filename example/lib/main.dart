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
  List<int> _nums = [0];

  int _num = 1;

  ExpandableSliverListController<int> _controller =
      ExpandableSliverListController<int>();

  void _toggleList() {
    if (_controller.isCollapsed()) {
      _controller.expand();
    } else {
      _controller.collapse();
    }
  }

  @override
  Widget build(BuildContext context) {
    _controller.setItems(_nums);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              setState(() {
                _controller.insertItem(_num, _num);
                _nums.insert(_num, _num);

                _num++;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.remove),
            onPressed: () {
              setState(() {
                _num--;

                _nums.removeAt(_num);
                _controller.removeItem(_num);
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _nums = [0, 1, 2, 3];
                _num = 4;
              });
            },
          )
        ],
      ),
      body: CustomScrollView(
        slivers: [
          ExpandableSliverList<int>(
            initialItems: _nums,
            controller: _controller,
            duration: const Duration(milliseconds: 500),
            builder: (context, item, index) {
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
