part of 'infinite_list_bloc.dart';

class InfiniteListState<T> {
  final List<T> items;

  InfiniteListState({required this.items});

  factory InfiniteListState.empty() {
    return InfiniteListState(items: []);
  }

  InfiniteListState<T> copyWith({
    List<T>? items,
  }) {
    return InfiniteListState(
      items: items ?? this.items,
    );
  }

  InfiniteListState<T> moreItems({
    required List<T> newItems,
  }) {
    return InfiniteListState(items: this.items..addAll(newItems));
  }
}

abstract class BaseInfiniteListState<T> extends Equatable {
  final InfiniteListState<T> state;

  const BaseInfiniteListState(this.state);

  @override
  List<Object> get props => [state];
}

class InitialState<T> extends BaseInfiniteListState<T> {
  InitialState() : super(InfiniteListState.empty());
}

class LoadingState<T> extends BaseInfiniteListState<T> {
  const LoadingState(super.state);
}

class LoadedState<T> extends BaseInfiniteListState<T> {
  const LoadedState(super.state);
}

class NoMoreItemsState<T> extends BaseInfiniteListState<T> {
  const NoMoreItemsState(super.state);
}

class ErrorState<T> extends BaseInfiniteListState<T> {
  final Exception error;

  const ErrorState(super.state, {required this.error});

  @override
  List<Object> get props => [state, error];
}
