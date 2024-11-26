import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'infinite_list_bloc/infinite_list_bloc.dart';

/// A widget that displays a scrollable list of items using an [InfiniteListBloc].
///
/// The [InfiniteListView] handles pagination and infinite scrolling by listening
/// to the scroll position and dispatching events to load more items when needed.
///
/// Example usage:
/// ```dart
/// InfiniteListView<MyItem>(
///   bloc: myInfiniteListBloc,
///   itemBuilder: (context, item) => ListTile(title: Text(item.title)),
///   loadingWidget: (context) => CircularProgressIndicator(),
///   errorWidget: (context, error) => Text('Error: $error'),
///   emptyWidget: (context) => Text('No items found'),
///   noMoreItemWidget: (context) => Text('No more items'),
/// );
/// ```
class InfiniteListView<T> extends StatefulWidget {
  /// The BLoC responsible for fetching and managing the list items.
  final InfiniteListBloc<T> bloc;

  /// A function that builds the widget for each item in the list.
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// A widget to display while the list is loading.
  final Widget Function(BuildContext context)? loadingWidget;

  /// A widget to display when an error occurs.
  final Widget Function(BuildContext context, String error)? errorWidget;

  /// A widget to display when there are no items in the list.
  final Widget Function(BuildContext context)? emptyWidget;

  /// A widget to display when there are no more items in the list.
  final Widget Function(BuildContext context)? noMoreItemWidget;

  /// A widget to display between the items in the list.
  final Widget? dividerWidget;

  /// The padding for the list view.
  final EdgeInsetsGeometry? padding;

  /// The background color of the list view.
  final Color? backgroundColor;

  /// The border radius of the list view.
  final BorderRadiusGeometry? borderRadius;

  /// The border color of the list view.
  final Color borderColor;

  /// The border width of the list view.
  final double borderWidth;

  /// The box shadow for the list view.
  final List<BoxShadow>? boxShadow;

  /// The physics for the scroll view.
  final ScrollPhysics? physics;

  /// Creates an [InfiniteListView] widget.
  const InfiniteListView({
    super.key,
    required this.bloc,
    required this.itemBuilder,
    this.loadingWidget,
    this.errorWidget,
    this.emptyWidget,
    this.noMoreItemWidget,
    this.dividerWidget,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.borderColor = Colors.transparent,
    this.borderWidth = 1,
    this.boxShadow,
    this.physics,
  });

  @override
  State<InfiniteListView<T>> createState() => _InfiniteListViewState<T>();
}

class _InfiniteListViewState<T> extends State<InfiniteListView<T>> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Load initial items
    widget.bloc.add(LoadItemsEvent());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Called whenever the scroll position changes.
  void _onScroll() {
    if (_isBottom) {
      // Trigger loading more items when scrolled to the bottom
      final currentState = widget.bloc.state;
      if (currentState is LoadedState<T>) {
        widget.bloc.add(LoadMoreItemsEvent());
      }
    }
  }

  /// Checks if the scroll position is at the bottom.
  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    const threshold = 200.0; // Adjust the threshold as needed
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    return (maxScroll - currentScroll) <= threshold;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InfiniteListBloc<T>, BaseInfiniteListState<T>>(
      bloc: widget.bloc,
      builder: (context, state) {
        if (state is InitialState<T>) {
          return _loadingWidget(context);
        } else if (state is ErrorState<T>) {
          return _errorWidget(context, state.error.toString());
        } else if (state is LoadedState<T> ||
            state is NoMoreItemsState<T> ||
            state is LoadingState<T>) {
          final items = state.state.items;
          if (items.isEmpty) {
            return _emptyWidget(context);
          }

          return RefreshIndicator(
            onRefresh: () async {
              widget.bloc.add(LoadItemsEvent());
              // Wait for the bloc to emit a LoadedState or ErrorState
              await widget.bloc.stream.firstWhere(
                  (state) => state is LoadedState<T> || state is ErrorState<T>);
            },
            child: Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: widget.borderRadius,
                border: Border.all(
                  color: widget.borderColor,
                  width: widget.borderWidth,
                ),
                boxShadow: widget.boxShadow,
              ),
              child: ListView.separated(
                controller: _scrollController,
                physics:
                    widget.physics ?? const AlwaysScrollableScrollPhysics(),
                itemCount: items.length + 1,
                // Add one for the bottom indicator
                separatorBuilder: (context, index) =>
                    widget.dividerWidget ?? const SizedBox.shrink(),
                itemBuilder: (context, index) {
                  if (index < items.length) {
                    return widget.itemBuilder(context, items[index]);
                  } else {
                    // Bottom indicator
                    return _buildBottomIndicator(state);
                  }
                },
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  /// Builds the bottom indicator widget based on the current state.
  Widget _buildBottomIndicator(BaseInfiniteListState<T> state) {
    if (state is LoadingState<T>) {
      return _loadingWidget(context);
    } else if (state is NoMoreItemsState<T>) {
      return _noMoreItemWidget(context);
    } else {
      return const SizedBox.shrink();
    }
  }

  /// Builds the widget for the loading indicator.
  Widget _loadingWidget(BuildContext context) {
    return widget.loadingWidget?.call(context) ??
        const Center(child: CircularProgressIndicator());
  }

  /// Builds the widget for displaying an error.
  Widget _errorWidget(BuildContext context, String error) {
    return widget.errorWidget?.call(context, error) ??
        Center(child: Text('Error: $error'));
  }

  /// Builds the widget for an empty list.
  Widget _emptyWidget(BuildContext context) {
    return widget.emptyWidget?.call(context) ??
        const Center(child: Text('No items'));
  }

  /// Builds the widget for when there are no more items in the list.
  Widget _noMoreItemWidget(BuildContext context) {
    return widget.noMoreItemWidget?.call(context) ??
        const Center(child: Text('No more items'));
  }
}
