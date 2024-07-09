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
        itemBuilder: (context, item) =>
            ListTile(
              title: Text(item.name),
            ),
        loadingWidget: (context) => Center(child: CircularProgressIndicator()),
        errorWidget: (context, error) => Center(child: Text('Error: $error')),
        emptyWidget: (context) => Center(child: Text('No items available')),
      ),
    );
  }
}
```

### Parameters

- `bloc` (required): The instance of your BLoC that extends `InfiniteListBloc`.
- `itemBuilder` (required): A function that builds the widget for each item in the list.
- `loadingWidget`: A widget to display while the list is loading.
- `errorWidget`: A widget to display when an error occurs.
- `emptyWidget`: A widget to display when there are no items in the list.
- `padding`: Padding for the list view.

### Example

Here is a more detailed example showing how to use the InfiniteListView with a BLoC:

```dart
class MyItem {
  final String name;

  MyItem(this.name);
}

class MyListBloc extends InfiniteListBloc<MyItem> {
  @override
  Future<List<MyItem>> fetchItems(int offset) async {
    await Future.delayed(Duration(seconds: 2)); // Simulate network delay
    return List.generate(20, (index) => MyItem('Item ${index + offset}'));
  }
}

class MyListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MyListBloc bloc = MyListBloc();

    return Scaffold(
      appBar: AppBar(title: Text('Infinite ListView Example')),
      body: InfiniteListView<MyItem>(
        bloc: bloc,
        itemBuilder: (context, item) =>
            ListTile(
              title: Text(item.name),
            ),
        loadingWidget: (context) => Center(child: CircularProgressIndicator()),
        errorWidget: (context, error) => Center(child: Text('Error: $error')),
        emptyWidget: (context) => Center(child: Text('No items available')),
      ),
    );
  }
}
```

### Installation

Add the following dependency to your `pubspec.yaml` file:

```yaml
flutter pub add bloc_infinity_list
```

### Conclusion

The **Infinite ListView** widget provides an easy and efficient way to implement infinite scrolling
in your Flutter applications. By leveraging the power of BLoC and debouncing, it ensures a smooth
user experience while keeping your code clean and maintainable.
