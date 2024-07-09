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
  static const int limit = 10;

  /// Initializes the InfiniteListBloc with an initial state of [InitialState].
  InfiniteListBloc() : super(InitialState<T>()) {
    on<LoadItemsEvent>((event, emit) async {
      debugPrint("\n LoadItemsEvent...");

      try {
        emit(LoadingState(state.state));
        final List<T> items = await fetchItems(limit: limit, offset: 0);
        debugPrint("Items fetched: ${items.length}");
        emit(LoadedState(state.state.copyWith(items: items)));
      } catch (e) {
        debugPrint("Error fetching items: $e");
        emit(ErrorState(state.state, error: e as Exception));
      }
      debugPrint("LoadItemsEvent!\n");
    });

    on<LoadMoreItemsEvent>((event, emit) async {
      debugPrint("\n LoadMoreItemsEvent...");

      try {
        emit(LoadingState(state.state));
        final List<T> items = await fetchItems(
          limit: event.limit ?? limit,
          offset: event.offset ?? state.state.items.length,
        );
        debugPrint("More items fetched: ${items.length}");
        if (items.isEmpty) {
          emit(NoMoreItemsState(state.state));
        } else {
          emit(LoadedState(state.state.moreItems(newItems: items)));
        }
      } catch (e) {
        debugPrint("Error fetching more items: $e");
        emit(ErrorState(state.state, error: e as Exception));
      }
      debugPrint("LoadMoreItemsEvent!\n");
    });
  }

  /// Abstract method to be implemented by subclasses to fetch items from an external source.
  ///
  /// This method should be overridden to define how items are fetched based on the provided [limit]
  /// and [offset].
  Future<List<T>> fetchItems({required int limit, required int offset});
}
