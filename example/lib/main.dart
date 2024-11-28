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
  Future<List<ListItem>> fetchItems({
    required int limit,
    required int offset,
  }) async {
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
      home: const HomePage(),
    );
  }
}

/// The home page that contains navigation to the two examples.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// State class for [HomePage].
class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AutomaticInfiniteListPage(),
    const ManualInfiniteListPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Infinite ListView Example'),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.autorenew),
            label: 'Automatic',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.touch_app),
            label: 'Manual',
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

/// A page demonstrating the automatic infinite list.
class AutomaticInfiniteListPage extends StatefulWidget {
  const AutomaticInfiniteListPage({super.key});

  @override
  State<AutomaticInfiniteListPage> createState() =>
      _AutomaticInfiniteListPageState();
}

class _AutomaticInfiniteListPageState extends State<AutomaticInfiniteListPage> {
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
      child: InfiniteListView<ListItem>.automatic(
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
        itemBuilder: _buildListItem,
        dividerWidget: const SizedBox(height: 0),
        loadingWidget: _buildLoadingWidget,
        errorWidget: _buildErrorWidget,
        emptyWidget: _buildEmptyWidget,
        noMoreItemWidget: _buildNoMoreItemWidget,
      ),
    );
  }

  Widget _buildListItem(BuildContext context, ListItem item) {
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
  }

  Widget _buildLoadingWidget(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
        ),
      );

  Widget _buildErrorWidget(BuildContext context, String error) => Center(
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
      );

  Widget _buildEmptyWidget(BuildContext context) => Center(
        child: Text(
          'No items available',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 18,
          ),
        ),
      );

  Widget _buildNoMoreItemWidget(BuildContext context) => Center(
        child: Text(
          'You have reached the end!',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 16,
          ),
        ),
      );
}

/// A page demonstrating the manual infinite list with a "Load More" button.
class ManualInfiniteListPage extends StatefulWidget {
  const ManualInfiniteListPage({super.key});

  @override
  State<ManualInfiniteListPage> createState() => _ManualInfiniteListPageState();
}

class _ManualInfiniteListPageState extends State<ManualInfiniteListPage> {
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
      child: InfiniteListView<ListItem>.manual(
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
        itemBuilder: _buildListItem,
        loadMoreButtonBuilder: _buildLoadMoreButton,
        dividerWidget: const SizedBox(height: 0),
        loadingWidget: _buildLoadingWidget,
        errorWidget: _buildErrorWidget,
        emptyWidget: _buildEmptyWidget,
        noMoreItemWidget: _buildNoMoreItemWidget,
      ),
    );
  }

  Widget _buildListItem(BuildContext context, ListItem item) {
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
  }

  Widget _buildLoadMoreButton(BuildContext context) {
    final state = _bloc.state;
    final isLoading = state is LoadingState<ListItem>;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () {
                _bloc.add(LoadMoreItemsEvent());
              },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Load More',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
      ),
    );
  }

  Widget _buildLoadingWidget(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
        ),
      );

  Widget _buildErrorWidget(BuildContext context, String error) => Center(
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
      );

  Widget _buildEmptyWidget(BuildContext context) => Center(
        child: Text(
          'No items available',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 18,
          ),
        ),
      );

  Widget _buildNoMoreItemWidget(BuildContext context) => Center(
        child: Text(
          'You have reached the end!',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 16,
          ),
        ),
      );
}
