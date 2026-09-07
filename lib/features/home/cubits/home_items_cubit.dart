import 'package:eClassify/features/item/models/item_preview.dart';
import 'package:eClassify/features/location/models/leaf_location.dart';
import 'package:eClassify/features/home/repository/home_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class HomeItemsState {}

class HomeItemsInitial extends HomeItemsState {}

class HomeItemsLoading extends HomeItemsState {}

class HomeItemsSuccess extends HomeItemsState {
  HomeItemsSuccess({required this.items, required this.total, this.message});

  final List<ItemPreview> items;
  final int total;
  final String? message;
}

class HomeItemsFailure extends HomeItemsState {
  final dynamic error;

  HomeItemsFailure(this.error);
}

class HomeItemsCubit extends Cubit<HomeItemsState> {
  HomeItemsCubit() : super(HomeItemsInitial());

  final HomeRepository _homeRepository = HomeRepository.instance;

  int page = 1;
  bool hasMore = true;
  bool isLoadingMore = false;

  void getHomeItems({LeafLocation? location}) async {
    try {
      emit(HomeItemsLoading());
      page = 1;
      hasMore = true;
      isLoadingMore = false;

      final result = await _homeRepository.fetchHomeAllItems(
        location: location,
        page: 1,
      );

      hasMore = result.modelList.length < result.total;

      emit(
        HomeItemsSuccess(
          items: result.modelList,
          total: result.total,
          message: result.extraData?.data as String?,
        ),
      );
    } catch (e) {
      emit(HomeItemsFailure(e.toString()));
    }
  }

  Future<void> getMoreHomeItems({required LeafLocation? location}) async {
    if (isLoadingMore || !hasMore || state is! HomeItemsSuccess) return;
    try {
      isLoadingMore = true;
      final nextPage = page + 1;
      final result = await _homeRepository.fetchHomeAllItems(
        page: nextPage,
        location: location,
      );

      final currentSuccessState = state as HomeItemsSuccess;
      final updatedList = List<ItemPreview>.from(currentSuccessState.items)
        ..addAll(result.modelList);

      page = nextPage;
      hasMore = updatedList.length < result.total;

      emit(
        HomeItemsSuccess(
          items: updatedList,
          total: result.total,
          message: result.extraData?.data as String?,
        ),
      );
    } catch (e) {
      final currentSuccessState = state as HomeItemsSuccess;
      emit(
        HomeItemsSuccess(
          items: currentSuccessState.items,
          total: currentSuccessState.total,
          message: currentSuccessState.message,
        ),
      );
      // Keep existing list but stop loading more on error, or customize as needed.
    } finally {
      isLoadingMore = false;
    }
  }

  bool get hasMoreData => hasMore;
}
