// infinite_list_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'infinite_list_bloc/infinite_list_bloc.dart';

/// An abstract class representing an infinite scrolling list view.
///
/// This class provides factory constructors to create instances of infinite
/// list views with different loading behaviors.
///
/// - [InfiniteListView.automatic]: Automatically loads more items when the
///   user scrolls to the bottom.
/// - [InfiniteListView.manual]: Provides a "Load More" button at the end of
///   the list for manual loading.
///
/// The [InfiniteListView] uses an [InfiniteListBloc] to manage the state and
/// loading of items.
///
/// ## Parameters
/// - [shrinkWrap]: Determines whether the extent of the scroll view in the
///   scrollDirection should be determined by the contents being viewed.
///   - **`true`**: The scroll view will size itself to the height of its
///     children. Useful when embedding the list within another scrollable widget.
///   - **`false`**: The scroll view will occupy all available space in the
///     scrollDirection. Suitable for standalone scrollable lists.
/// - [physics]: Determines the physics for the scroll view. Controls how the
///   scroll view behaves when user input is received.
///   - **`NeverScrollableScrollPhysics`**: Disables scrolling for the list.
///     Useful when the list is embedded within another scrollable widget.
///   - **`AlwaysScrollableScrollPhysics`** or other scroll physics: Enables
///     scrolling as per the specified behavior.
///
/// ## Usage Examples
///
/// ### Standalone Scrollable List
/// ```dart
/// InfiniteListView<MyItem>.automatic(
///   bloc: myInfiniteListBloc,
///   shrinkWrap: false, // Occupies all available space
///   physics: AlwaysScrollableScrollPhysics(), // Enables scrolling
///   itemBuilder: (context, item) => ListTile(title: Text(item.title)),
/// );
/// ```
///
/// ### Embedded within a SingleChildScrollView
/// ```dart
/// SingleChildScrollView(
///   child: Column(
///     children: [
///       // Other widgets
///       InfiniteListView<MyItem>.manual(
///         bloc: myInfiniteListBloc,
///         shrinkWrap: true, // Sizes to content
///         physics: NeverScrollableScrollPhysics(), // Delegates scrolling
///         itemBuilder: (context, item) => ListTile(title: Text(item.title)),
///         loadMoreButtonBuilder: (context) => ElevatedButton(
///           onPressed: () => myInfiniteListBloc.add(LoadMoreItemsEvent()),
///           child: Text('Load More'),
///         ),
///       ),
///       // Other widgets
///     ],
///   ),
/// );
/// ```
abstract class InfiniteListView<T> extends StatefulWidget {
  /// The BLoC responsible for fetching and managing the list items.
  final InfiniteListBloc<T> bloc;

  /// Determines whether the scroll view should shrink to fit its content.
  final bool shrinkWrap;

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
    required this.shrinkWrap,
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

  /// Factory constructor for automatic loading mode.
  ///
  /// Automatically loads more items when the user scrolls to the bottom of
  /// the list.
  factory InfiniteListView.automatic({
    Key? key,
    required InfiniteListBloc<T> bloc,
    required Widget Function(BuildContext context, T item) itemBuilder,
    // Optional parameters
    Widget Function(BuildContext context)? loadingWidget,
    Widget Function(BuildContext context, String error)? errorWidget,
    Widget Function(BuildContext context)? emptyWidget,
    Widget Function(BuildContext context)? noMoreItemWidget,
    Widget? dividerWidget,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    BorderRadiusGeometry? borderRadius,
    Color borderColor = Colors.transparent,
    double borderWidth = 1,
    List<BoxShadow>? boxShadow,
    ScrollPhysics? physics,
  }) {
    return _AutomaticInfiniteListView<T>(
      key: key,
      bloc: bloc,
      itemBuilder: itemBuilder,
      loadingWidget: loadingWidget,
      errorWidget: errorWidget,
      emptyWidget: emptyWidget,
      noMoreItemWidget: noMoreItemWidget,
      dividerWidget: dividerWidget,
      padding: padding,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      borderColor: borderColor,
      borderWidth: borderWidth,
      boxShadow: boxShadow,
      physics: physics,
    );
  }

  /// Factory constructor for manual loading mode.
  ///
  /// Provides a "Load More" button at the end of the list for manual loading
  /// of more items.
  factory InfiniteListView.manual({
    Key? key,
    required InfiniteListBloc<T> bloc,
    bool shrinkWrap = false,
    required Widget Function(BuildContext context, T item) itemBuilder,
    Widget Function(BuildContext context)? loadMoreButtonBuilder,
    // Optional parameters
    Widget Function(BuildContext context)? loadingWidget,
    Widget Function(BuildContext context, String error)? errorWidget,
    Widget Function(BuildContext context)? emptyWidget,
    Widget Function(BuildContext context)? noMoreItemWidget,
    Widget? dividerWidget,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    BorderRadiusGeometry? borderRadius,
    Color borderColor = Colors.transparent,
    double borderWidth = 1,
    List<BoxShadow>? boxShadow,
    ScrollPhysics? physics,
  }) {
    return _ManualInfiniteListView<T>(
      key: key,
      bloc: bloc,
      shrinkWrap: shrinkWrap,
      itemBuilder: itemBuilder,
      loadMoreButtonBuilder: loadMoreButtonBuilder,
      loadingWidget: loadingWidget,
      errorWidget: errorWidget,
      emptyWidget: emptyWidget,
      noMoreItemWidget: noMoreItemWidget,
      dividerWidget: dividerWidget,
      padding: padding,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      borderColor: borderColor,
      borderWidth: borderWidth,
      boxShadow: boxShadow,
      physics: physics,
    );
  }
}

/// A private class for the automatic infinite list view implementation.
///
/// Automatically loads more items when the user scrolls to the bottom.
class _AutomaticInfiniteListView<T> extends InfiniteListView<T> {
  const _AutomaticInfiniteListView({
    super.key,
    required super.bloc,
    required super.itemBuilder,
    super.shrinkWrap = false, // Typically false for standalone lists
    // Optional parameters
    super.loadingWidget,
    super.errorWidget,
    super.emptyWidget,
    super.noMoreItemWidget,
    super.dividerWidget,
    super.padding,
    super.backgroundColor,
    super.borderRadius,
    super.borderColor,
    super.borderWidth,
    super.boxShadow,
    super.physics,
  });

  @override
  State<InfiniteListView<T>> createState() =>
      _AutomaticInfiniteListViewState<T>();
}

class _AutomaticInfiniteListViewState<T>
    extends State<_AutomaticInfiniteListView<T>> {
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

  /// Checks if the scroll position is near the bottom.
  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    const threshold = 200.0; // Distance from bottom to trigger load
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
                // Default scroll physics
                shrinkWrap: widget.shrinkWrap,
                // Typically false for standalone lists
                itemCount: items.length + 1,
                // Add one for the bottom indicator
                separatorBuilder: (context, index) =>
                    widget.dividerWidget ?? const SizedBox.shrink(),
                itemBuilder: (context, index) {
                  if (index < items.length) {
                    return widget.itemBuilder(context, items[index]);
                  } else {
                    // Bottom indicator based on state
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

/// A private class for the manual infinite list view implementation.
///
/// Provides a "Load More" button at the end of the list for manual loading.
class _ManualInfiniteListView<T> extends InfiniteListView<T> {
  /// A builder for the "Load More" button when in manual mode.
  final Widget Function(BuildContext context)? loadMoreButtonBuilder;

  const _ManualInfiniteListView({
    super.key,
    required super.bloc,
    required super.shrinkWrap,
    required super.itemBuilder,
    this.loadMoreButtonBuilder,
    // Optional parameters
    super.loadingWidget,
    super.errorWidget,
    super.emptyWidget,
    super.noMoreItemWidget,
    super.dividerWidget,
    super.padding,
    super.backgroundColor,
    super.borderRadius,
    super.borderColor,
    super.borderWidth,
    super.boxShadow,
    super.physics,
  });

  @override
  State<InfiniteListView<T>> createState() => _ManualInfiniteListViewState<T>();
}

class _ManualInfiniteListViewState<T>
    extends State<_ManualInfiniteListView<T>> {
  @override
  void initState() {
    super.initState();

    // Load initial items
    widget.bloc.add(LoadItemsEvent());
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
                // Respect the shrinkWrap parameter
                shrinkWrap: widget.shrinkWrap,
                physics: widget.physics ??
                    (widget.shrinkWrap
                        ? const NeverScrollableScrollPhysics()
                        : const AlwaysScrollableScrollPhysics()),
                // - If shrinkWrap is true, disable internal scrolling
                // - If shrinkWrap is false, enable scrolling based on the provided physics
                itemCount: items.length + 1,
                separatorBuilder: (context, index) =>
                    widget.dividerWidget ?? const SizedBox.shrink(),
                itemBuilder: (context, index) {
                  if (index < items.length) {
                    return widget.itemBuilder(context, items[index]);
                  } else {
                    // "Load More" button or indicator
                    return _buildLoadMoreButton(state);
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

  /// Builds the "Load More" button or indicator based on the current state.
  Widget _buildLoadMoreButton(BaseInfiniteListState<T> state) {
    final isLoading = state is LoadingState<T>;
    final noMoreItems = state is NoMoreItemsState<T>;

    if (noMoreItems) {
      return _noMoreItemWidget(context);
    }

    return Center(
      child: widget.loadMoreButtonBuilder?.call(context) ??
          ElevatedButton(
            key: const Key('loadMoreButton'), // Assigning a unique key here
            onPressed: isLoading
                ? null
                : () {
                    widget.bloc.add(LoadMoreItemsEvent());
                  },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.deepPurple,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2.0,
                    ),
                  )
                : const Text(
                    'Load More',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
          ),
    );
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
