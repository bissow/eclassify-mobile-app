import 'package:eClassify/features/item/repository/item_repository.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SafetyTipsListState {}

class SafetyTipsListInitial extends SafetyTipsListState {}

class SafetyTipsListLoading extends SafetyTipsListState {}

class SafetyTipsListSuccess extends SafetyTipsListState {
  SafetyTipsListSuccess({required this.tips});

  final List<String> tips;
}

class SafetyTipsFailure extends SafetyTipsListState {}

class SafetyTipsListCubit extends Cubit<SafetyTipsListState> {
  SafetyTipsListCubit() : super(SafetyTipsListInitial());

  Future<void> fetchSafetyTips() async {
    if (state case SafetyTipsListSuccess s) {
      emit(SafetyTipsListSuccess(tips: s.tips));
      return;
    }
    try {
      emit(SafetyTipsListLoading());

      final tips = await ItemRepository.instance.getSafetyTips();
      emit(SafetyTipsListSuccess(tips: tips));
    } on Exception catch (e, st) {
      Log.error(e.toString(), e, st);
      emit(SafetyTipsFailure());
    }
  }
}
