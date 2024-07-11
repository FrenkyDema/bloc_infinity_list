## Infinite ListView for Flutter

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

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'infinite_list_bloc/infinite_list_bloc.dart';
import 'infinite_list_view.dart';

class MyListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final InfiniteListBloc<MyItem> bloc = InfiniteListBloc();

    return Scaffold(
      appBar: AppBar(title: Text('Infinite ListView Example')),
      body: InfiniteListView<MyItem>(
        bloc: bloc,
        itemBuilder: (context, item) => ListTile(title: Text(item.name)),
        dividerWidget: Divider(), // Custom divider between items
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