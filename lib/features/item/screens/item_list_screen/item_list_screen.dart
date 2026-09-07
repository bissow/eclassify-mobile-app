import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/utils/collection_notifiers.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/core/widgets/feedback/q_error_widget.dart';
import 'package:eClassify/core/widgets/feedback/shimmer_loading_container.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/features/item/cubits/item_list_cubit.dart';
import 'package:eClassify/features/item/models/item_list.dart';
import 'package:eClassify/features/item/models/item_preview.dart';
import 'package:eClassify/features/item/models/searched_item.dart';
import 'package:eClassify/features/item/screens/item_list_screen/item_list_bottom_bar.dart';
import 'package:eClassify/features/item/screens/item_list_screen/item_search_bar.dart';
import 'package:eClassify/features/item/screens/widgets/item_card.dart';
import 'package:eClassify/features/item/storage/search_history_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ItemListScreen extends StatefulWidget {
  const ItemListScreen({required this.metadata, super.key});

  final ItemMetaData metadata;

  @override
  State<ItemListScreen> createState() => _ItemListScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => BlocProvider(
        create: (_) => ItemListCubit(),
        child: ItemListScreen(
          metadata: routeSettings.arguments as ItemMetaData,
        ),
      ),
    );
  }
}

class _ItemListScreenState extends State<ItemListScreen> {
  late ItemMetaData metadata = widget.metadata;
  final ValueNotifier<ItemDisplayType> _displayType = ValueNotifier(
    ItemDisplayType.list,
  );
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);

  late final ListNotifier<SearchedItem> _searchHistory = ListNotifier([]);

  @override
  void initState() {
    super.initState();
    metadata.sortBy = null;
    metadata.filter = metadata.filter.copyWith(
      location: AppSession.currentLocation,
    );
    _scrollController.addListener(() {
      if (_scrollController.hasClients &&
          _scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          context.read<ItemListCubit>().hasMore) {
        _isLoading.value = true;
        context.read<ItemListCubit>().loadMoreItems(metadata: metadata);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _retrieveSearchHistory(),
    );
  }

  @override
  void dispose() {
    _searchHistory.dispose();
    _isLoading.dispose();
    _scrollController.dispose();
    _displayType.dispose();
    super.dispose();
  }

  void _getItems() {
    context.read<ItemListCubit>().getItemList(metadata: metadata);
    if (_scrollController.hasClients &&
        _scrollController.position.hasContentDimensions) {
      _scrollController.jumpTo(0);
    }
  }

  Widget _buildItemsShimmer(BuildContext context) {
    return Container(
      height: 120,
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1.5,
          color: context.colorScheme.onSurface.withValues(alpha: .05),
        ),
        color: context.colorScheme.secondary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        spacing: 10,
        children: [
          CustomShimmer(height: 120, width: 100),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomShimmer(width: 100, height: 10, borderRadius: 7),
              CustomShimmer(width: 150, height: 10, borderRadius: 7),
              CustomShimmer(width: 120, height: 10, borderRadius: 7),
              CustomShimmer(width: 80, height: 10, borderRadius: 7),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridItemsShimmer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: context.mutedColor.withValues(alpha: 0.13),
          width: 1,
        ),
        color: context.colorScheme.secondary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomShimmer(
                height: constraints.maxHeight * .6,
                width: double.infinity,
                borderRadius: 18,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomShimmer(width: 80, height: 10, borderRadius: 7),
                      CustomShimmer(width: 120, height: 10, borderRadius: 7),
                      CustomShimmer(width: 100, height: 10, borderRadius: 7),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _loaderWidget() {
    return SizedBox(
      height: kToolbarHeight,
      child: ValueListenableBuilder(
        valueListenable: _isLoading,
        builder: (context, value, child) {
          return value ? LoadingIndicator() : const SizedBox.shrink();
        },
      ),
    );
  }

  void _retrieveSearchHistory() async {
    try {
      final items = await SearchHistoryStorage.getSearchHistory();
      _searchHistory.replaceAll(items);
    } catch (_) {
      _searchHistory.clear();
      SearchHistoryStorage.clearSearchHistory();
    }
  }

  void _addItemToSearchHistory(ItemPreview item) {
    final searchedItem = SearchedItem.fromItem(item);
    if (!_searchHistory.contains(searchedItem)) {
      if (_searchHistory.length == 5) {
        _searchHistory.removeAt(0);
      }
      _searchHistory.add(searchedItem);
    }
  }

  Widget _searchHistoryWidget() {
    return ListenableBuilder(
      listenable: _searchHistory,
      builder: (context, child) {
        if (_searchHistory.isEmpty) return const SizedBox.shrink();
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('recentSearches'.translate(context))),
                AppButton(
                  variant: AppButtonVariant.text,
                  width: AppButtonWidth.content,
                  foregroundColor: context.colorScheme.primary,
                  onPressed: () {
                    _searchHistory.clear();
                  },
                  title: 'clear',
                ),
              ],
            ),
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 150),
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  children: _searchHistory.reversed.map((item) {
                    return ListTile(
                      tileColor: context.colorScheme.surface,
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          Routes.adDetailsScreen,
                          arguments: {'item_id': item.id},
                        );
                      },
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(AppIcons.clockClockwise),
                      title: RichText(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: item.name,
                              style: context.bodyMedium,
                            ),
                            // TextSpan(
                            //   text:
                            //       ' ${'in'.translate(context)} ${item.category.localized}',
                            //   style: TextStyle(
                            //     fontSize: context.font.normal,
                            //     fontWeight: FontWeight.bold,
                            //     color: context.colorScheme.onSurface,
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        SearchHistoryStorage.storeSearchHistory(_searchHistory.value);
        Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: context.colorScheme.surface,
        appBar: AppBar(
          backgroundColor: context.colorScheme.secondary,
          title: Text(metadata.title),
          bottom: ItemSearchBar(
            autoFocus: metadata is SearchMetaData,
            onSearch: (query) {
              metadata.search = query;
              _getItems();
            },
            displayType: _displayType,
          ),
        ),
        bottomNavigationBar: ItemListBottomBar(
          metadata: metadata,
          onSortChanged: (value) {
            metadata.sortBy = value;
            _getItems();
          },
          onFilterChanged: (filter) {
            if (filter == null) return;
            metadata.filter = filter;
            _getItems();
          },
        ),
        body: Padding(
          padding: Constant.appContentPadding,
          child: RefreshIndicator(
            onRefresh: () async => _getItems(),
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: ClampingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (metadata is SearchMetaData) _searchHistoryWidget(),
                  BlocConsumer<ItemListCubit, ItemListState>(
                    listener: (context, state) {
                      if (state is ItemListSuccess ||
                          state is ItemListFailure) {
                        _isLoading.value = false;
                      }
                    },
                    builder: (context, state) {
                      if (state is ItemListInitial) {
                        _getItems();
                      }
                      if (state is ItemListFailure) {
                        return QErrorWidget(
                          error: state.error,
                          onRetry: _getItems,
                        );
                      }
                      if (state is ItemListSuccess) {
                        if (state.items.isEmpty) {
                          return const QErrorWidget.emptyData();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: RefreshIndicator(
                            onRefresh: () async => _getItems(),
                            child: ValueListenableBuilder(
                              valueListenable: _displayType,
                              builder: (context, value, child) {
                                return value == ItemDisplayType.list
                                    ? ListView.separated(
                                        shrinkWrap: true,
                                        itemCount: state.items.length,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) =>
                                            ItemCard.list(
                                              item: state.items[index],
                                              onTap: () {
                                                _addItemToSearchHistory(
                                                  state.items[index],
                                                );
                                                Navigator.of(context).pushNamed(
                                                  Routes.adDetailsScreen,
                                                  arguments: {
                                                    'item_id':
                                                        state.items[index].id,
                                                    'preview':
                                                        state.items[index],
                                                  },
                                                );
                                              },
                                            ),
                                        separatorBuilder: (_, _) => 10.vGap,
                                      )
                                    : GridView.builder(
                                        shrinkWrap: true,
                                        itemCount: state.items.length,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              childAspectRatio: .65,
                                              mainAxisSpacing: 15,
                                              crossAxisSpacing: 15,
                                            ),
                                        itemBuilder: (context, index) =>
                                            ItemCard.grid(
                                              item: state.items[index],
                                              onTap: () {
                                                _addItemToSearchHistory(
                                                  state.items[index],
                                                );
                                                Navigator.of(context).pushNamed(
                                                  Routes.adDetailsScreen,
                                                  arguments: {
                                                    'item_id':
                                                        state.items[index].id,
                                                    'preview':
                                                        state.items[index],
                                                  },
                                                );
                                              },
                                            ),
                                      );
                              },
                            ),
                          ),
                        );
                      }
                      return ValueListenableBuilder<ItemDisplayType>(
                        valueListenable: _displayType,
                        builder: (context, value, child) {
                          if (value == ItemDisplayType.list) {
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: 10,
                              itemBuilder: (context, index) {
                                return _buildItemsShimmer(context);
                              },
                            );
                          } else {
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: 10,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: .65,
                                    mainAxisSpacing: 15,
                                    crossAxisSpacing: 15,
                                  ),
                              itemBuilder: (context, index) =>
                                  _buildGridItemsShimmer(context),
                            );
                          }
                        },
                      );
                    },
                  ),
                  _loaderWidget(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
