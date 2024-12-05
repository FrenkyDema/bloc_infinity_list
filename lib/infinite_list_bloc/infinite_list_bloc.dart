import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'infinite_list_event.dart';
part 'infinite_list_state.dart';

/// Abstract class representing a BLoC (Business Logic Component) for handling infinite lists.
///
/// This BLoC manages the state of an infinite list, handling events to load initial items and
/// more items as the user scrolls. It extends [Bloc] and emits [BaseInfiniteListState]s.
abstract class InfiniteListBloc<T>
    extends Bloc<InfiniteListEvent, BaseInfiniteListState<T>> {
  /// Default limit for fetching items in a single request.
  late int defaultLimit = 10;

  /// A list of initial items to preload, if any.
  final List<T>? initialItems;

  /// Initializes the InfiniteListBloc with an initial state.
  ///
  /// Optionally accepts [initialItems] to set up the initial state.
  InfiniteListBloc({
    this.initialItems,
    int? limitFetch,
  }) : super(
          initialItems != null && initialItems.isNotEmpty
              ? LoadedState<T>(
                  InfiniteListState<T>(
                    items: initialItems,
                  ),
                )
              : InitialState<T>(),
        ) {
    defaultLimit = limitFetch ?? 10;
    on<LoadItemsEvent>(_onLoadItems);
    on<LoadMoreItemsEvent>(_onLoadMoreItems);
  }

  /// Handler for [LoadItemsEvent].
  Future<void> _onLoadItems(
      LoadItemsEvent event, Emitter<BaseInfiniteListState<T>> emit) async {
    debugPrint("\nLoadItemsEvent...");

    try {
      // If initial items are provided, emit them directly.
      if (initialItems != null && initialItems!.isNotEmpty) {
        debugPrint("Initial items are provided. Emitting initial items.");
        emit(LoadedState<T>(InfiniteListState<T>(items: initialItems!)));
      }
      // Otherwise, fetch items from the data source.
      else {
        emit(InitialState<T>());
        final List<T> items = await fetchItems(limit: defaultLimit, offset: 0);
        debugPrint("Items fetched: ${items.length}");
        emit(LoadedState<T>(InfiniteListState<T>(items: items)));
      }
    } catch (e) {
      debugPrint("Error fetching items: $e");
      emit(ErrorState<T>(
        state.state,
        error: e is Exception ? e : Exception(e.toString()),
      ));
    }
    debugPrint("LoadItemsEvent!\n");
  }

  /// Handler for [LoadMoreItemsEvent].
  Future<void> _onLoadMoreItems(
      LoadMoreItemsEvent event, Emitter<BaseInfiniteListState<T>> emit) async {
    debugPrint("\nLoadMoreItemsEvent...");

    try {
      emit(LoadingState<T>(state.state));
      final List<T> items = await fetchItems(
        limit: event.limit ?? defaultLimit,
        offset: state.state.items.length,
      );
      debugPrint("More items fetched: ${items.length}");
      if (items.isEmpty) {
        emit(NoMoreItemsState<T>(state.state));
      } else {
        emit(LoadedState<T>(state.state.moreItems(newItems: items)));
      }
    } catch (e) {
      debugPrint("Error fetching more items: $e");
      emit(ErrorState<T>(
        state.state,
        error: e is Exception ? e : Exception(e.toString()),
      ));
    }
    debugPrint("LoadMoreItemsEvent!\n");
  }

  /// Abstract method to be implemented by subclasses to fetch items from an external source.
  ///
  /// This method should be overridden to define how items are fetched based on the provided [limit]
  /// and [offset].
  Future<List<T>> fetchItems({required int limit, required int offset});
}
