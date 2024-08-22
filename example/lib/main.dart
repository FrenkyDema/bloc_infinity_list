import 'dart:async';

import 'package:bloc_infinity_list/bloc_infinity_list.dart';
import 'package:bloc_infinity_list/infinite_list_bloc/infinite_list_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ListItem {
  static int staticId = 0;

  final int id;
  final String name;

  ListItem({required this.name}) : id = ++staticId;
}

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

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final MyCustomBloc bloc = MyCustomBloc();

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Infinite ListView Example'),
        ),
        body: BlocProvider.value(
          value: bloc,
          child: InfiniteListView<ListItem>(
            bloc: bloc,
            color: Colors.black12,
            borderRadius: BorderRadius.circular(10),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
            itemBuilder: (context, item) {
              return ListTile(
                title: Text(item.name),
                subtitle: Text('ID: ${item.id}'),
              );
            },
            dividerWidget: const Divider(),
            loadingWidget: (context) => Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(20),
              child: CircularProgressIndicator.adaptive(
                strokeWidth: 2.0,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            errorWidget: (context, error) => Center(
              child: Text(
                'Error: $error',
                style: const TextStyle(color: Colors.red),
              ),
            ),
            emptyWidget: (context) => const Center(
              child: Text('No items available'),
            ),
            noMoreItemWidget: (context) => const Center(
              child: Text('No more items available'),
            ),
          ),
        ),
      ),
    );
  }
}
