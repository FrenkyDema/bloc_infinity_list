## Infinite ListView for Flutter

[![pub package](https://img.shields.io/pub/v/bloc_infinity_list.svg)](https://pub.dev/packages/bloc_infinity_list)
[![Build Status](https://img.shields.io/github/actions/workflow/status/frenkydema/bloc_infinity_list/flutter.yml)](https://github.com/frenkydema/bloc_infinity_list/actions/workflows/flutter.yml)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

### Overview

The **Infinite ListView** widget is designed to simplify the creation of paginated lists in your
Flutter application. This widget integrates seamlessly with the BLoC pattern and allows you to load
more items as the user scrolls to the bottom of the list.

### Features

- **Automatic Pagination**: Load more items automatically when the user reaches the bottom of the
  list.
- **Refresh Control**: Pull-to-refresh functionality to reload the entire list.
- **Customizable UI**: Easily customize loading, error, and empty state widgets.
- **Debounced Scrolling**: Prevents multiple loading triggers in rapid succession, ensuring
  efficient data fetching.
- **BLoC Integration**: Works with `flutter_bloc` to manage states and events, ensuring a clean and
  maintainable codebase.
- **UI Customization**: Customize the list container with color, border radius, border color, border
  width, and box shadow.
- **Custom Dividers**: Add custom dividers between list items using the `dividerWidget`.

### Usage

To use the Infinite ListView, you need to provide an instance of your BLoC and an item builder. The
BLoC should handle loading initial items and fetching more items as needed.

#### Creating a Custom BLoC

Extend the `InfiniteListBloc` class to create your custom BLoC. Override the `fetchItems` method to
define how items are fetched. Here’s an example of a custom BLoC implementation:

```dart
import 'package:bloc_infinity_list/bloc_infinity_list.dart';

class MyCustomBloc extends InfiniteListBloc<ListItem> {
  @override
  Future<List<ListItem>> fetchItems(
      {required int limit, required int offset}) async {
    try {
      await Future.delayed(Durations.long1);

      if (offset >= 50) {
        return [];
      }

      return List.generate(
          limit, (index) => ListItem(name: 'Item ${offset + index + 1}'));
    } on Exception {
      rethrow;
    }
  }
}
```

#### Example Usage

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_infinity_list/bloc_infinity_list.dart';

class MyListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MyCustomBloc bloc = MyCustomBloc();

    return Scaffold(
      appBar: AppBar(title: Text('Infinite ListView Example')),
      body: InfiniteListView<ListItem>(
        bloc: bloc,
        itemBuilder: (context, item) => ListTile(title: Text(item.name)),
        dividerWidget: Divider(),
        loadingWidget: (context) => Center(child: CircularProgressIndicator()),
        errorWidget: (context, error) => Center(child: Text('Error: $error')),
        emptyWidget: (context) => Center(child: Text('No items available')),
        padding: EdgeInsets.all(16.0),
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        borderColor: Colors.grey,
        borderWidth: 2.0,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5.0)],
      ),
    );
  }
}
```