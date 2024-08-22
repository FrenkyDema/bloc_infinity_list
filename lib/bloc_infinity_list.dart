import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'infinite_list_bloc/infinite_list_bloc.dart';

/// A widget that displays a scrollable list of items using a [InfiniteListBloc].
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
  final Color? color;

  /// The border radius of the list view.
  final BorderRadiusGeometry? borderRadius;

  /// The border color of the list view.
  final Color borderColor;

  /// The border width of the list view.
  final double borderWidth;

  /// The box shadow for the list view.
  final List<BoxShadow>? boxShadow;

  /// Constructs an [InfiniteListView] widget.
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
    this.color,
    this.borderRadius,
    this.borderColor = Colors.transparent,
    this.borderWidth = 1,
    this.boxShadow,
  });

  @override
  State<InfiniteListView<T>> createState() => _InfiniteListViewState<T>();
}

class _InfiniteListViewState<T> extends State<InfiniteListView<T>> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    widget.bloc.add(LoadItemsEvent());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  /// Handles the scroll events and triggers loading more items if scrolled to the bottom.
  void _onScroll() {
    if (_debounce?.isActive ?? false) return;
    if (_isBottom && !_isLoadingMore) {
      _loadMore();
    }
    _debounce = Timer(Durations.medium1, () {
      setState(() {
        _isLoadingMore = false;
      });
    });
  }

  /// Checks if the list view is scrolled to the bottom.
  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final double maxScroll = _scrollController.position.maxScrollExtent;
    final double currentScroll = _scrollController.offset;

    final BaseInfiniteListState<T> currentState = widget.bloc.state;

    return currentState is LoadedState<T> && currentScroll >= maxScroll;
  }

  /// Initiates the loading of more items.
  void _loadMore() {
    setState(() {
      _isLoadingMore = true;
    });
    widget.bloc.add(LoadMoreItemsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InfiniteListBloc<T>, BaseInfiniteListState<T>>(
      bloc: widget.bloc,
      builder: (context, state) {
        if (state is InitialState<T>) {
          return _loadingWidget(context);
        } else if (state is ErrorState<T>) {
          return _errorWidget(context, state.error);
        } else if (state is LoadedState<T> ||
            state is NoMoreItemsState<T> ||
            state is LoadingState<T>) {
          if (state.state.items.isEmpty) {
            return _emptyWidget(context);
          }

          return RefreshIndicator(
            color: Theme.of(context).iconTheme.color,
            backgroundColor: Theme.of(context).cardTheme.color,
            onRefresh: () async {
              widget.bloc.add(LoadItemsEvent());
              await widget.bloc.stream
                  .firstWhere((event) => event is LoadingState);
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(
                    decelerationRate: ScrollDecelerationRate.fast),
              ),
              child: Container(
                margin: widget.padding ?? EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: widget.borderRadius,
                  shape: BoxShape.rectangle,
                  border: Border.all(
                    color: widget.borderColor,
                    width: widget.borderWidth,
                  ),
                  boxShadow: widget.boxShadow,
                ),
                child: Column(
                  children: List.generate(
                    state is LoadedState<T>
                        ? state.state.items.length
                        : state.state.items.length + 1,
                    (index) {
                      if (index >= state.state.items.length) {
                        return _bottomIndicator(context, state);
                      }
                      return Column(
                        children: [
                          widget.itemBuilder(context, state.state.items[index]),
                          index + 1 < state.state.items.length
                              ? widget.dividerWidget ?? const SizedBox.shrink()
                              : const SizedBox.shrink(),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        }
        return Container();
      },
    );
  }

  /// Builds the widget for the bottom indicator based on the current state.
  Widget _bottomIndicator(
      BuildContext context, BaseInfiniteListState<T> state) {
    return switch (state) {
      LoadingState() => _loadingWidget(context),
      NoMoreItemsState<T>() => _noMoreItemWidget(context),
      _ => const SizedBox(),
    };
  }

  /// Builds the widget for when there are no more items in the list.
  Widget _noMoreItemWidget(BuildContext context) =>
      widget.noMoreItemWidget?.call(context) ??
      Center(
        child: Text(
          'No more items',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );

  /// Builds the widget for an empty list.
  Widget _emptyWidget(BuildContext context) =>
      widget.emptyWidget?.call(context) ??
      Center(
        child: Text(
          'No items',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );

  /// Builds the widget for the loading indicator.
  Widget _loadingWidget(BuildContext context) {
    return widget.loadingWidget?.call(context) ??
        const Center(child: CircularProgressIndicator.adaptive());
  }

  /// Builds the widget for displaying an error.
  Widget _errorWidget(BuildContext context, Exception error) {
    return widget.errorWidget?.call(context, error.toString()) ??
        Center(child: Text(error.toString()));
  }
}
