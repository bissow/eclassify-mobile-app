import 'package:eClassify/features/category/models/category.dart';
import 'package:eClassify/features/item/models/item_filter.dart';
import 'package:eClassify/core/network/api.dart';
import 'package:eClassify/core/network/api_params.dart';
import 'package:eClassify/core/utils/json_helper.dart';

enum Sort {
  popular('popular', 'popular_items'),
  newToOld('newToOld', 'new-to-old'),
  oldToNew('oldToNew', 'old-to-new'),
  priceHighToLow('priceHighToLow', 'price-high-to-low'),
  priceLowToHigh('priceLowToHigh', 'price-low-to-high');

  const Sort(this.label, this.value);

  final String label;
  final String value;
}

sealed class ItemMetaData {
  ItemMetaData({
    required this.title,
    this.search,
    Sort? sort,
    ItemFilter? filter,
  }) : sortBy = sort?.value ?? Sort.popular.value,
       filter = filter ?? ItemFilter();

  final String title;
  String? search;
  String? sortBy;
  ItemFilter filter;

  Json get toJson => {
    ApiParams.search: ?search,
    ApiParams.sortBy: ?sortBy,
    ...filter.toJson,
  };
}

class SectionMetaData extends ItemMetaData {
  SectionMetaData({required this.sectionId, required super.title});

  final int sectionId;

  @override
  Json get toJson => {ApiParams.featuredSectionId: sectionId, ...super.toJson};
}

class CategoryMetaData extends ItemMetaData {
  CategoryMetaData({required Category category})
    : super(
        filter: ItemFilter(category: category),
        title: category.name.localized,
      );
}

class SearchMetaData extends ItemMetaData {
  SearchMetaData({required super.title});
}
