import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'infinite_list_bloc/infinite_list_bloc.dart';

/// A widget that displays a scrollable list of items using a [InfiniteListBloc].
class InfiniteListView<T> extends StatefulWidget {
  final InfiniteListBloc<T> bloc;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final Widget Function(BuildContext context)? loadingWidget;
  final Widget Function(BuildContext context, String error)? errorWidget;
  final Widget Function(BuildContext context)? emptyWidget;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  final BorderRadiusGeometry? borderRadius;
  final Color borderColor;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;

  /// Constructs an [InfiniteListView] widget.
  const InfiniteListView({
    super.key,
    required this.bloc,
    required this.itemBuilder,
    this.loadingWidget,
    this.errorWidget,
    this.emptyWidget,
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
                    state is NoMoreItemsState<T>
                        ? state.state.items.length
                        : state.state.items.length + 1,
                    (index) {
                      if (index >= state.state.items.length) {
                        return _bottomIndicator(context, state);
                      }
                      return widget.itemBuilder(
                          context, state.state.items[index]);
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
      NoMoreItemsState<T>() => _emptyWidget(context),
      _ => const SizedBox(),
    };
  }

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
