import 'package:eClassify/features/user_profile/cubits/user_profile_cubit.dart';
import 'package:eClassify/features/banner/cubits/banner_ad_cubit.dart';
import 'package:eClassify/features/category/cubits/main_category_cubit.dart';
import 'package:eClassify/features/chat/cubits/chat_list_cubit.dart';
import 'package:eClassify/features/chat/cubits/seller_item_offers_cubit.dart';
import 'package:eClassify/core/cubits/currencies_cubit.dart';
import 'package:eClassify/features/followers/cubits/follow_user_list_cubit.dart';
import 'package:eClassify/features/home/cubits/featured_section_cubit.dart';
import 'package:eClassify/features/home/cubits/home_items_cubit.dart';
import 'package:eClassify/features/home/cubits/home_screen_configuration_cubit.dart';
import 'package:eClassify/features/home/cubits/popular_categories_cubit.dart';
import 'package:eClassify/features/home/cubits/slider_cubit.dart';
import 'package:eClassify/features/reels/cubits/video_ads_cubit.dart';
import 'package:eClassify/features/location/cubits/leaf_location_cubit.dart';
import 'package:eClassify/core/cubits/bottom_nav_cubit.dart';
import 'package:eClassify/features/banner/models/banner_ad.dart';
import 'package:eClassify/features/home/models/home_section.dart';
import 'package:eClassify/features/location/models/leaf_location.dart';
import 'package:eClassify/core/widgets/ads/google_banner_ad.dart';
import 'package:eClassify/features/home/screens/mixins/root_location_resolver_mixin.dart';
import 'package:eClassify/features/home/screens/widgets/all_items_widget.dart';
import 'package:eClassify/features/home/screens/widgets/category/all_category_widget.dart';
import 'package:eClassify/features/home/screens/widgets/category/popular_category_widget.dart';
import 'package:eClassify/features/home/screens/widgets/featured_section/featured_section_widget.dart';
import 'package:eClassify/features/home/screens/widgets/home_screen_shimmer.dart';
import 'package:eClassify/features/home/screens/widgets/home_search.dart';
import 'package:eClassify/features/home/screens/widgets/location_widget.dart';
import 'package:eClassify/features/home/screens/widgets/slider_widget.dart';
import 'package:eClassify/features/banner/screens/banner_widget.dart';
import 'package:eClassify/core/widgets/feedback/q_error_widget.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/app/widgets/bottom_nav_tap_listener.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/generic_extensions.dart';
import 'package:eClassify/core/extensions/scroll_extension.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with
        AutomaticKeepAliveClientMixin,
        WidgetsBindingObserver,
        RootLocationResolverMixin {
  final ValueNotifier<bool> _isInitialLoad = ValueNotifier(
    AppSession.currentLocation == null,
  );
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    context.read<BottomNavCubit>().changeTab(BottomTab.home);
    _loadHomeScreenData();
    if (AppSession.isAuthenticated) {
      _loadUserData();
    }
  }

  @override
  void dispose() {
    _isInitialLoad.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    context.read<BuyingChatListCubit>().getChatUsers();
    context.read<SellerItemOffersCubit>().getOffers();
    context.read<UserProfileCubit>().getUserProfile();
    // To fill the profile screen data
    context.read<FollowingListCubit>().getUsers();
    context.read<FollowersListCubit>().getUsers();
  }

  Future<void> _loadHomeScreenData() async {
    final location = AppSession.currentLocation;
    if (location == null) return;

    final fetchAllItems = switch (context
        .read<HomeConfigurationCubit>()
        .state) {
      HomeConfigurationSuccess(:final sections) => sections.any(
        (section) => section.type == HomeSectionType.allAds,
      ),
      _ => false,
    };

    context.read<FeaturedSectionCubit>().fetch(location: location);
    if (fetchAllItems) {
      context.read<HomeItemsCubit>().getHomeItems(location: location);
    }
    context.read<SliderCubit>().fetchSliders(location: location);
    context.read<MainCategoryCubit>().fetch(forceRefresh: true);
    context.read<PopularCategoriesCubit>().getCategories();
    context.read<CurrenciesCubit>().fetchCurrencies();
    context.read<HomeBannerAdCubit>().fetchBanners();
    _isInitialLoad.value = false;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BottomNavTapListener(
      listenFor: BottomTab.home,
      onTap: () {
        if (!_scrollController.hasClients) return;
        if (_scrollController.position.pixels != 0) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutQuad,
          );
        } else {
          _loadHomeScreenData();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: double.maxFinite,
          leading: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Constant.horizontalPadding,
            ),
            child: LocationWidget(),
          ),
        ),
        body: BlocListener<LeafLocationCubit, LeafLocation?>(
          listener: (context, location) {
            _loadHomeScreenData();
            context.read<VideoAdsCubit>().getVideoAds(
              location: AppSession.currentLocation,
            );
          },
          child: BlocConsumer<HomeConfigurationCubit, HomeConfigurationState>(
            listener: (context, state) {
              if (state is HomeConfigurationLoading) {
                _isInitialLoad.value = true;
              }
              if (state is HomeConfigurationSuccess) {
                _loadHomeScreenData();
              }
              if (state is HomeConfigurationFailure) {
                Log.error(state.error.toString(), state.error, null);
                _isInitialLoad.value = false;
              }
            },
            builder: (context, state) {
              if (state is HomeConfigurationLoading) {
                return HomeScreenShimmer();
              }
              if (state is HomeConfigurationFailure) {
                return QErrorWidget(
                  error: state.error,
                  onRetry: () {
                    context
                        .read<HomeConfigurationCubit>()
                        .getHomeConfiguration();
                  },
                );
              }
              if (state is HomeConfigurationSuccess) {
                if (state.sections.isNullOrEmpty) {
                  return QErrorWidget.emptyData(
                    onRetry: () {
                      context
                          .read<HomeConfigurationCubit>()
                          .getHomeConfiguration();
                    },
                  );
                }

                return ValueListenableBuilder(
                  valueListenable: _isInitialLoad,
                  builder: (context, value, child) {
                    return value ? const HomeScreenShimmer() : child!;
                  },
                  child: Builder(
                    builder: (context) {
                      context.watch<HomeBannerAdCubit>();
                      final bannersByKey = context
                          .read<HomeBannerAdCubit>()
                          .homeBannersByKey;

                      return RefreshIndicator(
                        onRefresh: _loadHomeScreenData,
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            // Only listen to notifications from the main CustomScrollView
                            if (notification.depth != 0) return false;

                            if (notification.isNearBottom &&
                                context.read<HomeItemsCubit>().hasMoreData) {
                              context.read<HomeItemsCubit>().getMoreHomeItems(
                                location: AppSession.currentLocation,
                              );
                            }
                            return false;
                          },
                          child: CustomScrollView(
                            controller: _scrollController,
                            physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics(),
                            ),
                            slivers: _slivers(state.sections, bannersByKey),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _slivers(
    List<HomeSection> sections,
    HomeSectionBannerMap bannersByKey,
  ) {
    Widget? _resolveAdBannerWidget(int sectionId, BannerPlacement placement) {
      final banner = bannersByKey[(sectionId, placement)];

      return banner != null
          ? SliverToBoxAdapter(child: BannerWidget(bannerAd: banner))
          : null;
    }

    final slivers = List<Widget>.empty(growable: true);

    slivers.add(SliverToBoxAdapter(child: HomeSearchField()));

    for (final section in sections) {
      slivers.addAll([
        ?_resolveAdBannerWidget(section.id, BannerPlacement.above),
        ?_maybeAddGoogleBannerAd(section.type),
        HomeSectionFactory.getSectionWidget(section),
        ?_resolveAdBannerWidget(section.id, BannerPlacement.below),
      ]);
    }

    return slivers;
  }

  Widget? _maybeAddGoogleBannerAd(HomeSectionType type) {
    if (!Constant.systemSettings.isBannerAdEnabled) return null;
    if (type != HomeSectionType.allAds) return null;
    return SliverToBoxAdapter(child: GoogleBannerAd());
  }
}

class HomeSectionFactory {
  static Widget getSectionWidget(HomeSection section) {
    return switch (section.type) {
      HomeSectionType.categoryList => SliverToBoxAdapter(
        child: const AllCategoryWidget(),
      ),
      HomeSectionType.slider => SliverToBoxAdapter(child: const SliderWidget()),
      HomeSectionType.popularCategories => SliverToBoxAdapter(
        child: const PopularCategoryWidget(),
      ),
      HomeSectionType.featuredSection => const FeaturedSectionWidget(),
      HomeSectionType.allAds => const AllItemsWidget(),
    };
  }
}
