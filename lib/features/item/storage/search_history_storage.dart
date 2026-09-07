import 'package:eClassify/core/storage/hive_keys.dart';
import 'package:eClassify/core/storage/hive_storage.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:eClassify/features/item/models/searched_item.dart';

/// Backed by [HiveKeys.historyBox], which is opened on demand rather than at
/// boot: search history is only touched once the user opens item search.
class SearchHistoryStorage {
  SearchHistoryStorage._();

  static Future<bool> storeSearchHistory(List<SearchedItem> items) async {
    try {
      final jsonList = items.map((element) => element.toJson);
      await HiveStorage.addAllAsync(HiveKeys.historyBox, jsonList);
      return true;
    } on Exception catch (e, st) {
      Log.error(e.toString(), e, st);
      return false;
    }
  }

  static Future<List<SearchedItem>> getSearchHistory() async {
    final jsonList = await HiveStorage.valuesOfAsync(HiveKeys.historyBox);
    return jsonList.map((e) => SearchedItem.fromJson(e)).toList();
  }

  static Future<void> clearSearchHistory() =>
      HiveStorage.clearBox(HiveKeys.historyBox);
}
