import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'infinite_list_event.dart';
part 'infinite_list_state.dart';

abstract class InfiniteListBloc<T>
    extends Bloc<InfiniteListEvent, BaseInfiniteListState<T>> {
  static const int limit = 10;

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

  Future<List<T>> fetchItems({required int limit, required int offset});
}
