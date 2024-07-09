part of 'infinite_list_bloc.dart';

abstract class InfiniteListEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadItemsEvent extends InfiniteListEvent {}

class LoadMoreItemsEvent extends InfiniteListEvent {
  final int? limit;
  final int? offset;

  LoadMoreItemsEvent({this.limit, this.offset});
}
