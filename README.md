# BLoC Infinite List for Flutter

[![pub package](https://img.shields.io/pub/v/bloc_infinity_list.svg)](https://pub.dev/packages/bloc_infinity_list)
[![Build Status](https://img.shields.io/github/actions/workflow/status/frenkydema/bloc_infinity_list/flutter.yml)](https://github.com/frenkydema/bloc_infinity_list/actions/workflows/flutter.yml)
[![Publish Status](https://img.shields.io/github/actions/workflow/status/frenkydema/bloc_infinity_list/publish.yml)](https://github.com/frenkydema/bloc_infinity_list/actions/workflows/publish.yml)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Overview

The **BLoC Infinite List** widget simplifies the creation of paginated lists in Flutter applications. It integrates seamlessly with the BLoC pattern, enabling you to automatically load more items as users scroll to the bottom of the list.

## Features

- **Automatic Pagination**: Load more items automatically when the user scrolls to the end of the list.
- **Refresh Control**: Built-in pull-to-refresh functionality to reload the entire list.
- **Customizable UI**: Easily customize widgets for loading, error, and empty states.
- **Debounced Scrolling**: Prevents rapid loading triggers with debounced scrolling for efficient data fetching.
- **BLoC Integration**: Works with `flutter_bloc` for state and event management, ensuring clean and maintainable code.
- **UI Customization**: Customize the list view with color, border radius, border color, border width, and box shadow.
- **Custom Dividers**: Add custom dividers between items with the `dividerWidget`.

## Usage

To use `BLoC Infinite List`, provide your BLoC instance and an item builder. The BLoC should manage loading the initial items and fetching more as needed.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc_infinity_list_bloc/bloc_infinity_list_bloc.dart';
import 'bloc_infinity_list_view.dart';

class MyListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final BLoCInfiniteListBloc<MyItem> bloc = BLoCInfiniteListBloc();

    return Scaffold(
      appBar: AppBar(title: Text('BLoC Infinite List Example')),
      body: BLoCInfiniteListView<MyItem>(
        bloc: bloc,
        itemBuilder: (context, item) => ListTile(title: Text(item.name)),
        dividerWidget: Divider(),
        loadingWidget: (context) => Center(child: CircularProgressIndicator()),
        errorWidget: (context, error) => Center(child: Text('Error: $error')),
        emptyWidget: (context) => Center(child: Text('No items available')),
        noMoreItemWidget: (context) => Center(child: Text('No more items')),
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

## Demo

See how `BLoC Infinite List` works in action! Watch the demo video below or check out the screenshots:

[![Demo Video](https://img.youtube.com/vi/your-video-id/0.jpg)](https://www.youtube.com/watch?v=your-video-id)

## Installation

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  bloc_infinity_list: ^0.0.6
```

Then run `flutter pub get` to install the package.

## License

`BLoC Infinite List` is licensed under the [MIT License](LICENSE).

## Contact

For questions or feedback, please reach out via [GitHub Issues](https://github.com/FrenkyDema/bloc_infinity_list/issues/new/choose).
```