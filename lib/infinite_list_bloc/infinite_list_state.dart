part of 'infinite_list_bloc.dart';

/// Represents the state of the list containing items of type [T].
class InfiniteListState<T> {
  /// The list of items of type [T].
  final List<T> items;

  /// Constructs an instance of [InfiniteListState] with the given [items].
  InfiniteListState({required this.items});

  /// Factory method to create an empty [InfiniteListState] instance.
  factory InfiniteListState.empty() {
    return InfiniteListState(items: []);
  }

  /// Creates a copy of [InfiniteListState] with the given fields replaced.
  InfiniteListState<T> copyWith({
    List<T>? items,
  }) {
    return InfiniteListState(
      items: items ?? this.items,
    );
  }

  /// Creates a copy of [InfiniteListState] with additional [newItems] appended to [items].
  InfiniteListState<T> moreItems({
    required List<T> newItems,
  }) {
    return InfiniteListState(items: [...this.items, ...newItems]);
  }
}

/// Abstract base class for states in the InfiniteListBloc.
///
/// States represent different states of the list loading and its content.
abstract class BaseInfiniteListState<T> extends Equatable {
  /// The current [InfiniteListState] of type [T].
  final InfiniteListState<T> state;

  /// Constructs a [BaseInfiniteListState] with the given [state].
  const BaseInfiniteListState(this.state);

  @override
  List<Object> get props => [state];
}

/// Represents the initial state of the InfiniteListBloc.
class InitialState<T> extends BaseInfiniteListState<T> {
  /// Constructs an [InitialState] with an empty [InfiniteListState].
  InitialState() : super(InfiniteListState.empty());
}

/// Represents the loading state of the InfiniteListBloc.
class LoadingState<T> extends BaseInfiniteListState<T> {
  /// Constructs a [LoadingState] with the given [state].
  const LoadingState(super.state);
}

/// Represents the loaded state of the InfiniteListBloc.
class LoadedState<T> extends BaseInfiniteListState<T> {
  /// Constructs a [LoadedState] with the given [state].
  const LoadedState(super.state);
}

/// Represents the state indicating no more items in the InfiniteListBloc.
class NoMoreItemsState<T> extends BaseInfiniteListState<T> {
  /// Constructs a [NoMoreItemsState] with the given [state].
  const NoMoreItemsState(super.state);
}

/// Represents the error state of the InfiniteListBloc.
class ErrorState<T> extends BaseInfiniteListState<T> {
  /// The error associated with this state.
  final Exception error;

  /// Constructs an [ErrorState] with the given [state] and [error].
  const ErrorState(super.state, {required this.error});

  @override
  List<Object> get props => [state, error];
}
