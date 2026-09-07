import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/utils/debounce_mixin.dart';
import 'package:flutter/material.dart';

enum ItemDisplayType { list, grid }

class ItemSearchBar extends StatefulWidget implements PreferredSizeWidget {
  const ItemSearchBar({
    required this.onSearch,
    required this.displayType,
    this.autoFocus = true,
    super.key,
  });

  final bool autoFocus;
  final ValueChanged<String?> onSearch;
  final ValueNotifier<ItemDisplayType> displayType;

  @override
  State<ItemSearchBar> createState() => _ItemSearchBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _ItemSearchBarState extends State<ItemSearchBar>
    with DebounceMixin<ItemSearchBar, String?> {
  final TextEditingController _searchController = TextEditingController();
  late final FocusNode _focusNode = FocusNode(
    canRequestFocus: widget.autoFocus,
  );

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void onDebounced(String? value) {
    if (value == null || value.isEmpty) {
      widget.onSearch(null);
    } else {
      widget.onSearch(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        spacing: 5,
        children: [
          Expanded(
            child: TextField(
              focusNode: _focusNode,
              autofocus: widget.autoFocus,
              controller: _searchController,
              onChanged: debounce,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: context.colorScheme.primary),
                ),
                hintText: 'searchHint'.translate(context),
                hintStyle: TextStyle(color: context.mutedColor),
                prefixIcon: Icon(
                  AppIcons.magnifyingGlass,
                  color: context.colorScheme.primary,
                ),
                prefixIconConstraints: BoxConstraints.tight(Size.square(38)),
                constraints: BoxConstraints(maxHeight: 48),
              ),
              onTapOutside: (_) {
                _focusNode.unfocus();
              },
            ),
          ),
          IconButton(
            style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              fixedSize: Size.square(48),
            ),
            onPressed: () => widget.displayType.value = ItemDisplayType.list,
            icon: ValueListenableBuilder(
              valueListenable: widget.displayType,
              builder: (context, value, child) {
                final icon = value == ItemDisplayType.list
                    ? AppIcons.squareSplitVerticalFill
                    : AppIcons.squareSplitVertical;
                return Icon(icon, color: context.colorScheme.onSurface);
              },
            ),
          ),
          IconButton(
            style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              fixedSize: Size.square(48),
            ),
            onPressed: () => widget.displayType.value = ItemDisplayType.grid,
            icon: ValueListenableBuilder(
              valueListenable: widget.displayType,
              builder: (context, value, child) {
                final icon = value == ItemDisplayType.grid
                    ? AppIcons.gridFourFill
                    : AppIcons.gridFour;
                return Icon(icon, color: context.colorScheme.onSurface);
              },
            ),
          ),
        ],
      ),
    );
  }
}
