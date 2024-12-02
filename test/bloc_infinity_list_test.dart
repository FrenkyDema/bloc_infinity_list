// test/bloc_infinity_list_test.dart

import 'package:bloc_infinity_list/bloc_infinity_list.dart';
import 'package:bloc_infinity_list/infinite_list_bloc/infinite_list_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// A simple data class representing an item in the list.
class ListItem {
  static int _staticId = 0;

  final int id;
  final String name;
  final String description;

  ListItem({required this.name, required this.description}) : id = ++_staticId;

  /// Resets the static ID counter. Useful for testing.
  static void resetIdCounter() {
    _staticId = 0;
  }
}

/// A custom BLoC that extends [InfiniteListBloc] to fetch [ListItem]s.
class MyCustomBloc extends InfiniteListBloc<ListItem> {
  MyCustomBloc({super.initialItems});

  @override
  Future<List<ListItem>> fetchItems({
    required int limit,
    required int offset,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));

    // Simulate end of data
    if (offset >= 20) {
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

// Subclasses for testing different scenarios

/// Bloc that returns an empty list to simulate no data.
class MyCustomBlocEmpty extends MyCustomBloc {
  @override
  Future<List<ListItem>> fetchItems({
    required int limit,
    required int offset,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return [];
  }
}

/// Bloc that throws an exception to simulate an error.
class MyCustomBlocError extends MyCustomBloc {
  @override
  Future<List<ListItem>> fetchItems({
    required int limit,
    required int offset,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    throw Exception('Network error');
  }
}

/// Bloc that returns different data on each fetch to simulate refresh.
class MyCustomBlocRefresh extends MyCustomBloc {
  bool isFirstLoad = true;

  @override
  Future<List<ListItem>> fetchItems({
    required int limit,
    required int offset,
  }) async {
    // Reset the ID counter on refresh
    if (offset == 0 && !isFirstLoad) {
      ListItem.resetIdCounter();
    }
    await Future.delayed(const Duration(milliseconds: 100));
    if (isFirstLoad) {
      // First load
      isFirstLoad = false;
      return List.generate(
        limit,
        (index) => ListItem(
          name: 'Item ${offset + index + 1}',
          description: 'Description',
        ),
      );
    } else {
      // After refresh
      return List.generate(
        limit,
        (index) => ListItem(
          name: 'Refreshed Item ${offset + index + 1}',
          description: 'Description',
        ),
      );
    }
  }
}

/// Bloc with a limited number of items to simulate "No more items".
class MyCustomBlocLimited extends MyCustomBloc {
  final int maxItems;

  MyCustomBlocLimited({required this.maxItems});

  @override
  Future<List<ListItem>> fetchItems({
    required int limit,
    required int offset,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (offset >= maxItems) return [];
    final remaining = maxItems - offset;
    final fetchLimit = remaining < limit ? remaining : limit;
    return List.generate(
      fetchLimit,
      (index) => ListItem(
        name: 'Item ${offset + index + 1}',
        description: 'Description for item ${offset + index + 1}',
      ),
    );
  }
}

/// Bloc that accepts initial items to simulate preloaded data.
class MyCustomBlocWithInitialItems extends MyCustomBloc {
  MyCustomBlocWithInitialItems({super.initialItems});
}

void main() {
  group('InfiniteListView Tests', () {
    testWidgets('Automatic Infinite List loads more items on scroll',
        (WidgetTester tester) async {
      final bloc = MyCustomBloc();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<MyCustomBloc>(
              create: (_) => bloc,
              child: InfiniteListView<ListItem>.automatic(
                bloc: bloc,
                itemBuilder: (context, item) {
                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text(item.description),
                  );
                },
                loadingWidget: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ),
        ),
      );

      // Initial load
      await tester.pumpAndSettle();

      // Scroll to the bottom to trigger loading more items
      await tester.scrollUntilVisible(find.text('Item 9'), 100);
      await tester.pump();
      await tester.drag(
        find.byType(ListView),
        const Offset(0, -500),
      );
      // Allow time for the loading indicator to appear
      await tester.pump(const Duration(milliseconds: 70));

      // Loading indicator should appear
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle(); // Wait for more items to load

      // Verify that more items are loaded
      expect(find.text('Item 1'), findsNothing);
      expect(find.text('Item 11'), findsOneWidget);
    });

    testWidgets('Manual Infinite List shows "Load More" button',
        (WidgetTester tester) async {
      final bloc = MyCustomBloc();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<MyCustomBloc>(
              create: (_) => bloc..add(LoadItemsEvent()),
              child: InfiniteListView<ListItem>.manual(
                bloc: bloc,
                itemBuilder: (context, item) {
                  return ListTile(
                    key: ValueKey(item.id),
                    title: Text(item.name),
                    subtitle: Text(item.description),
                  );
                },
                loadMoreButtonBuilder: (context) {
                  final state = bloc.state;

                  final isLoadingMore = state is LoadingState<ListItem> &&
                      state.state.items.isNotEmpty;

                  final noMoreItems = state is NoMoreItemsState<ListItem>;

                  if (noMoreItems) {
                    return const SizedBox.shrink();
                  }

                  if (state.state.items.isNotEmpty) {
                    return ElevatedButton(
                      key: const Key('loadMoreButton'),
                      onPressed: isLoadingMore
                          ? null
                          : () {
                              bloc.add(LoadMoreItemsEvent());
                            },
                      child: isLoadingMore
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Load More'),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
                loadingWidget: (context) =>
                    const Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
        ),
      );

      // Wait for the initial load
      await tester.pumpAndSettle();

      // Scroll to the bottom to bring 'Load More' button into view
      await tester.drag(
        find.byType(ListView),
        const Offset(0, -500), // Adjust the offset as needed
      );
      await tester.pumpAndSettle();

      // Verify that "Load More" button is visible
      expect(find.byKey(const Key('loadMoreButton')), findsOneWidget);
      expect(find.text('Load More'), findsOneWidget);
    });

    testWidgets('Manual Infinite List "Load More" button loads more items',
        (WidgetTester tester) async {
      final bloc = MyCustomBloc();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<MyCustomBloc>(
              create: (_) => bloc..add(LoadItemsEvent()),
              child: InfiniteListView<ListItem>.manual(
                bloc: bloc,
                itemBuilder: (context, item) {
                  return ListTile(
                    key: ValueKey(item.id),
                    title: Text(item.name),
                    subtitle: Text(item.description),
                  );
                },
                loadMoreButtonBuilder: (context) {
                  final state = bloc.state;

                  final isLoadingMore = state is LoadingState<ListItem> &&
                      state.state.items.isNotEmpty;

                  final noMoreItems = state is NoMoreItemsState<ListItem>;

                  if (noMoreItems) {
                    return const SizedBox.shrink();
                  }

                  if (state.state.items.isNotEmpty) {
                    return ElevatedButton(
                      key: const Key('loadMoreButton'),
                      onPressed: isLoadingMore
                          ? null
                          : () {
                              bloc.add(LoadMoreItemsEvent());
                            },
                      child: isLoadingMore
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Load More'),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
                loadingWidget: (context) =>
                    const Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
        ),
      );

      // Wait for the initial load
      await tester.pumpAndSettle();

      // Scroll to the bottom to bring 'Load More' button into view
      await tester.scrollUntilVisible(find.text('Load More'), 500);
      await tester.pumpAndSettle();

      // Ensure the "Load More" button is displayed
      expect(find.byKey(const Key('loadMoreButton')), findsOneWidget);
      expect(find.text('Load More'), findsOneWidget);

      // Tap the "Load More" button
      await tester.tap(find.byKey(const Key('loadMoreButton')));
      await tester.pump(); // Start loading more items

      // Wait for the loading indicator to appear on the button
      await tester.pump(const Duration(milliseconds: 70));

      // Verify that the loading indicator appears on the button
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for more items to load
      await tester.pumpAndSettle();

      // Verify that more items are loaded
      expect(find.text('Item 11'), findsOneWidget);
    });

    testWidgets('Infinite List shows empty state when no items are loaded',
        (WidgetTester tester) async {
      // Use the bloc that returns an empty list
      final bloc = MyCustomBlocEmpty();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<MyCustomBlocEmpty>(
              create: (_) => bloc..add(LoadItemsEvent()),
              child: InfiniteListView<ListItem>.automatic(
                bloc: bloc,
                itemBuilder: (context, item) {
                  return ListTile(
                    key: ValueKey(item.id),
                    title: Text(item.name),
                    subtitle: Text(item.description),
                  );
                },
                emptyWidget: (context) => const Center(
                  child: Text('No items available'),
                ),
                loadingWidget: (context) =>
                    const Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
        ),
      );

      // Wait for the initial load
      await tester.pumpAndSettle();

      // Verify that empty widget is displayed
      expect(find.text('No items available'), findsOneWidget);
      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('Infinite List shows error state when an error occurs',
        (WidgetTester tester) async {
      // Use the bloc that throws an exception
      final bloc = MyCustomBlocError();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<MyCustomBlocError>(
              create: (_) => bloc..add(LoadItemsEvent()),
              child: InfiniteListView<ListItem>.automatic(
                bloc: bloc,
                itemBuilder: (context, item) {
                  return ListTile(
                    key: ValueKey(item.id),
                    title: Text(item.name),
                    subtitle: Text(item.description),
                  );
                },
                errorWidget: (context, error) => Center(
                  child: Text('Error occurred: $error'),
                ),
                loadingWidget: (context) =>
                    const Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
        ),
      );

      // Start the initial loading and trigger the error
      await tester.pump(); // Start loading
      await tester.pump(const Duration(milliseconds: 100)); // Wait for error
      await tester.pumpAndSettle(); // Wait for the UI to update

      // Verify that error widget is displayed
      expect(find.textContaining('Error occurred:'), findsOneWidget);
      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('Infinite List shows "No more items" when all data is loaded',
        (WidgetTester tester) async {
      final bloc = MyCustomBlocLimited(maxItems: 20);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<MyCustomBloc>(
              create: (_) => bloc..add(LoadItemsEvent()),
              child: InfiniteListView<ListItem>.automatic(
                bloc: bloc,
                itemBuilder: (context, item) {
                  return ListTile(
                    key: ValueKey(item.id),
                    title: Text(item.name),
                    subtitle: Text(item.description),
                  );
                },
                noMoreItemWidget: (context) =>
                    const Center(child: Text('No more items')),
                loadingWidget: (context) =>
                    const Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
        ),
      );

      // Wait for the initial load
      await tester.pumpAndSettle();

      // Load all items by scrolling multiple times
      for (int i = 1; i <= 2; i++) {
        // Assuming limit=10 and maxItems=20
        // Scroll to the bottom to trigger loading more items
        await tester.scrollUntilVisible(find.text("Item ${10 * i}"), 100);

        // Wait for more items to load
        await tester.pumpAndSettle();
      }

      // Scroll to the bottom to bring 'No more items' widget into view
      await tester.drag(
        find.byType(ListView),
        const Offset(0, -500), // Adjust the offset as needed
      );
      await tester.pumpAndSettle();

      // Verify that "No more items" widget is displayed
      expect(find.text('No more items'), findsOneWidget);
    });

    testWidgets(
        'Manual Infinite List hides "Load More" when all data is loaded',
        (WidgetTester tester) async {
      // Initialize the bloc with a maximum of 10 items
      final bloc = MyCustomBlocLimited(maxItems: 10);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<MyCustomBlocLimited>(
              create: (_) => bloc..add(LoadItemsEvent()),
              child: InfiniteListView<ListItem>.manual(
                bloc: bloc,
                itemBuilder: (context, item) {
                  return ListTile(
                    key: ValueKey(item.id),
                    title: Text(item.name),
                    subtitle: Text(item.description),
                  );
                },
                loadMoreButtonBuilder: (context) {
                  final state = bloc.state;

                  // Determine if currently loading more items
                  final isLoadingMore = state is LoadingState<ListItem> &&
                      state.state.items.isNotEmpty;

                  // Determine if there are no more items
                  final noMoreItems = state is NoMoreItemsState<ListItem>;

                  if (noMoreItems) {
                    return const SizedBox.shrink();
                  }

                  if (state.state.items.isNotEmpty) {
                    return ElevatedButton(
                      // Removed key usage
                      onPressed: isLoadingMore
                          ? null
                          : () {
                              bloc.add(LoadMoreItemsEvent());
                            },
                      child: isLoadingMore
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Load More'),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
                noMoreItemWidget: (context) =>
                    const Center(child: Text('No more items')),
                loadingWidget: (context) =>
                    const Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
        ),
      );

      // Wait for the initial load to complete
      await tester.pumpAndSettle();

      // Verify that initial items are loaded
      expect(find.text('Item 1'), findsOneWidget);

      // Scroll to the bottom to bring "Load More" button into view
      await tester.scrollUntilVisible(
          find.text('Load More'), 100 // Adjust the offset as needed
          );
      await tester.pumpAndSettle();

      // Tap the "Load More" button
      await tester.tap(find.text('Load More'));
      await tester.pump(); // Start loading more items

      // Wait for the loading indicator to appear on the button
      await tester.pump(const Duration(milliseconds: 70));

      // Verify that the loading indicator appears on the button
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for more items to load
      await tester.pumpAndSettle();

      // After loading all items, "Load More" button should no longer be displayed
      expect(find.text('Load More'), findsNothing);

      // Scroll to the bottom to bring "No more items" widget into view
      await tester.scrollUntilVisible(find.text('No more items'), 100);
      await tester.pumpAndSettle();

      // Verify that "No more items" widget is displayed
      expect(find.text('No more items'), findsOneWidget);
    });

    testWidgets('Infinite List refreshes on pull down',
        (WidgetTester tester) async {
      final bloc = MyCustomBlocRefresh();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<MyCustomBlocRefresh>(
              create: (_) => bloc..add(LoadItemsEvent()),
              child: InfiniteListView<ListItem>.automatic(
                bloc: bloc,
                itemBuilder: (context, item) {
                  return ListTile(
                    key: ValueKey(item.id),
                    title: Text(item.name),
                    subtitle: Text(item.description),
                  );
                },
                loadingWidget: (context) =>
                    const Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
        ),
      );

      // Wait for the initial load
      await tester.pumpAndSettle();

      // Verify that initial items are loaded
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Refreshed Item 1'), findsNothing);

      // Perform pull-to-refresh by dragging down
      await tester.drag(
        find.byType(ListView),
        const Offset(0, 300), // Drag down by 300 pixels
      );
      await tester.pump(); // Start the refresh

      // Wait for the refresh indicator to appear
      await tester.pump(const Duration(milliseconds: 100));

      // Wait for the refresh to complete
      await tester.pumpAndSettle();

      // Verify that new items are loaded
      expect(find.text('Refreshed Item 1'), findsOneWidget);
      // Also check that old items are not present
      expect(find.text('Item 1'), findsNothing);
    });

    testWidgets('Infinite List handles scroll physics properly',
        (WidgetTester tester) async {
      final bloc = MyCustomBloc();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<MyCustomBloc>(
              create: (_) => bloc..add(LoadItemsEvent()),
              child: InfiniteListView<ListItem>.automatic(
                bloc: bloc,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, item) {
                  return ListTile(
                    key: ValueKey(item.id),
                    title: Text(item.name),
                    subtitle: Text(item.description),
                  );
                },
                loadingWidget: (context) =>
                    const Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
        ),
      );

      // Wait for the initial load
      await tester.pumpAndSettle();

      // Verify that the initial item is displayed
      expect(find.text('Item 1'), findsOneWidget);

      // Try to scroll the list
      await tester.drag(
        find.byType(ListView),
        const Offset(0, -100),
      );
      await tester.pump();

      // Verify that the list did not scroll (Item 1 is still visible)
      expect(find.text('Item 1'), findsOneWidget);
    });

    testWidgets(
      'Infinite List displays initial items correctly when initialized with initial items',
      (WidgetTester tester) async {
        // Define 5 initial items
        final initialItems = List.generate(
          5,
          (index) => ListItem(
            name: 'Initial Item ${index + 1}',
            description: 'Description for initial item ${index + 1}',
          ),
        );

        // Initialize the Test BLoC with initial items
        final bloc = MyCustomBlocWithInitialItems(initialItems: initialItems);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<MyCustomBlocWithInitialItems>(
                create: (_) => bloc,
                child: InfiniteListView<ListItem>.manual(
                  bloc: bloc,
                  itemBuilder: (context, item) {
                    return ListTile(
                      key: ValueKey(item.id),
                      title: Text(item.name),
                      subtitle: Text(item.description),
                    );
                  },
                  loadMoreButtonBuilder: (context) {
                    final state = bloc.state;
                    final isLoading = state is LoadingState<ListItem>;

                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        key: const Key('loadMoreButton'),
                        // Assigning a unique key here
                        onPressed: isLoading
                            ? null
                            : () {
                                bloc.add(LoadMoreItemsEvent());
                              },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Colors.deepPurple,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                  strokeWidth: 2.0,
                                ),
                              )
                            : const Text(
                                'Load More',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                      ),
                    );
                  },
                  loadingWidget: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, error) => Center(
                    child: Text('Error: $error'),
                  ),
                  emptyWidget: (context) => const Center(
                    child: Text('No items available'),
                  ),
                  noMoreItemWidget: (context) => const Center(
                    child: Text('No more items'),
                  ),
                ),
              ),
            ),
          ),
        );

        // Allow the initial items to be rendered
        await tester.pumpAndSettle();

        // Verify that the initial 5 items are displayed
        for (int i = 1; i <= 5; i++) {
          expect(find.text('Initial Item $i'), findsOneWidget);
          expect(find.text('Description for initial item $i'), findsOneWidget);
        }

        // Verify that no loading indicator is present initially
        expect(find.byType(CircularProgressIndicator), findsNothing);

        // Find and tap the "Load More" button
        final loadMoreButton = find.byKey(const Key('loadMoreButton'));
        expect(loadMoreButton, findsOneWidget);

        await tester.tap(loadMoreButton);
        await tester.pump(); // Start the tap event

        // Allow the BLoC to process the LoadMoreItemsEvent and emit LoadingState
        await tester.pump(); // This pump allows the BLoC to emit LoadingState

        // Verify that the loading indicator appears within the "Load More" button
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Wait for the fetchItems to complete (100ms as defined in BLoC)
        await tester.pump(const Duration(milliseconds: 100));

        // Allow all animations and state transitions to settle
        await tester.pumpAndSettle();

        // Verify that additional items are loaded
        expect(find.text('Item 6'), findsOneWidget);
        await tester.scrollUntilVisible(find.text("Item 10"), 100);
        expect(find.text('Item 10'), findsOneWidget);

        // Verify that initial items are still present
        await tester.scrollUntilVisible(find.text("Initial Item 1"), -100);
        for (int i = 1; i <= 5; i++) {
          expect(find.text('Initial Item $i'), findsOneWidget);
        }

        // Verify that no loading indicator is present after loading more items
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );
  });
}
