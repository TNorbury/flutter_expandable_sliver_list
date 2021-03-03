# expandable_sliver_list

[![pub package](https://img.shields.io/pub/v/expandable_sliver_list.svg)](https://pub.dev/packages/expandable_sliver_list)
[![flutter_tests](https://github.com/TNorbury/flutter_expandable_sliver_list/workflows/flutter%20tests/badge.svg)](https://github.com/TNorbury/flutter_expandable_sliver_list/actions?query=workflow%3A%22flutter+tests%22)
[![codecov](https://codecov.io/gh/TNorbury/flutter_expandable_sliver_list/branch/master/graph/badge.svg)](https://codecov.io/gh/TNorbury/flutter_expandable_sliver_list)
[![style: effective dart](https://img.shields.io/badge/style-effective_dart-40c4ff.svg)](https://pub.dev/packages/effective_dart)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A Flutter widget which creates a Sliver List that you can then either expand or collapse, in order to show or hide the contents of the list.

![](https://raw.githubusercontent.com/TNorbury/flutter_expandable_sliver_list/master/readme_assets/example.gif)

## Getting Started

### Installing

In your Flutter project, add the package to your dependencies

```yml
dependencies:
  ...
  expandable_sliver_list: ^4.0.0
```

### Usage Example

A complete example on how to use this widget can be found in the [example directory](https://github.com/TNorbury/flutter_expandable_sliver_list/tree/master/example).
But the basics are:

Import the package

```dart
import 'package:expandable_sliver_list/expandable_sliver_list.dart';
```

Create a controller and a list of items to display

```dart
ExpandableSliverListController controller = ExpandableSliverListController();

List<int> items = [1, 2, 3, 4, 5];
```

Create the widget

```dart
ExpandableSliverList<int>(
  initialItems: items,
  controller: controller,
  builder: (context, item, index) {
    return ListTile(
      title: Text(item.toString()),
    );
  },
)
```

Now you can use the controller to expand or collapse the list

```dart
controller.collapse();
controller.expand();
```

Or to add items to the list

```dart
controller.insertItem(54, 2);
controller.removeItem(4);
```
