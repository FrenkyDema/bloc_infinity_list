part of 'infinite_list_bloc.dart';

/// Abstract base class for events in the InfiniteListBloc.
///
/// Events are used to trigger state changes in the bloc.
abstract class InfiniteListEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event triggered to load initial items in the list.
class LoadItemsEvent extends InfiniteListEvent {}

/// Event triggered to load more items in the list.
///
/// Optionally accepts [limit] and [offset] parameters to customize the number of items
/// fetched and the starting position for fetching.
class LoadMoreItemsEvent extends InfiniteListEvent {
  final int? limit;
  final int? offset;

  LoadMoreItemsEvent({this.limit, this.offset});

  @override
  List<Object?> get props => [limit, offset];
}
