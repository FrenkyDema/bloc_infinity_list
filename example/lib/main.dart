import 'dart:async';

import 'package:bloc_infinity_list/bloc_infinity_list.dart';
import 'package:bloc_infinity_list/infinite_list_bloc/infinite_list_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A simple data class representing an item in the list.
class ListItem {
  static int _staticId = 0;

  final int id;
  final String name;
  final String description;

  ListItem({required this.name, required this.description}) : id = ++_staticId;
}

/// A custom BLoC that extends [InfiniteListBloc] to fetch [ListItem]s.
class MyCustomBloc extends InfiniteListBloc<ListItem> {
  @override
  Future<List<ListItem>> fetchItems(
      {required int limit, required int offset}) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Simulate end of data
    if (offset >= 50) {
      return [];
    }

    // Generate dummy data
    return List.generate(
      limit,
      (index) => ListItem(
        name: 'Item ${offset + index + 1}',
        description: 'Description for item ${offset + index + 1}',
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}

/// The root widget of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Infinite ListView Example',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16.0),
          titleLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
      ),
      home: const InfiniteListPage(),
    );
  }
}

/// A stateful widget that contains the infinite list page.
class InfiniteListPage extends StatefulWidget {
  const InfiniteListPage({super.key});

  @override
  State<InfiniteListPage> createState() => _InfiniteListPageState();
}

class _InfiniteListPageState extends State<InfiniteListPage> {
  late final MyCustomBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = MyCustomBloc();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MyCustomBloc>(
      create: (_) => _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Infinite ListView Example'),
        ),
        body: InfiniteListView<ListItem>(
          bloc: _bloc,
          backgroundColor: Colors.white,
          padding: const EdgeInsets.all(16.0),
          borderRadius: BorderRadius.circular(12.0),
          borderColor: Colors.grey.shade300,
          borderWidth: 1.0,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 6.0,
              spreadRadius: 2.0,
              offset: const Offset(0, 3),
            ),
          ],
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, item) {
            return Card(
              elevation: 2.0,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    item.id.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  item.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                subtitle: Text(
                  item.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Handle item tap
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tapped on ${item.name}')),
                  );
                },
              ),
            );
          },
          dividerWidget: const SizedBox(height: 0),
          loadingWidget: (context) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor),
              ),
            ),
          ),
          errorWidget: (context, error) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade300, size: 48),
                const SizedBox(height: 8),
                Text(
                  'Something went wrong!',
                  style: TextStyle(
                    color: Colors.red.shade300,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    _bloc.add(LoadItemsEvent());
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          emptyWidget: (context) => Center(
            child: Text(
              'No items available',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 18,
              ),
            ),
          ),
          noMoreItemWidget: (context) => Center(
            child: Text(
              'You have reached the end!',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
