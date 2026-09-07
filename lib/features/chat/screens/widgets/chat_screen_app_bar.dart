import 'package:eClassify/app/routes.dart';
import 'package:eClassify/features/chat/cubits/chat_session_cubit.dart';
import 'package:eClassify/features/chat/cubits/delete_chat_cubit.dart';
import 'package:eClassify/features/chat/cubits/user_block_cubit.dart';
import 'package:eClassify/features/advertisement/cubits/item_status_cubit.dart';
import 'package:eClassify/features/chat/models/chat.dart';
import 'package:eClassify/core/models/user_preview.dart';
import 'package:eClassify/features/chat/screens/inbox/widgets/chat_delete_confirmation_dialog.dart';
import 'package:eClassify/features/chat/screens/widgets/dialogs/block_user_dialog.dart';
import 'package:eClassify/core/widgets/images/profile_avatar.dart';
import 'package:eClassify/core/widgets/images/user_placeholder_image.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/utils/collection_notifiers.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/features/item/enums/item_status.dart';
import 'package:eClassify/core/extensions/generic_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatScreenAppBar({
    required this.user,
    required this.item,
    required this.selectionNotifier,
    required this.chatId,
    this.onDelete,
    this.isCurrentUserSeller = false,
    super.key,
  });

  final UserPreview user;
  final ChatItem item;
  final int chatId;
  final SetNotifier<int> selectionNotifier;
  final VoidCallback? onDelete;
  final bool isCurrentUserSeller;

  Future<void> _handleBlockUser(
    BuildContext context,
    bool isUserBlocked,
  ) async {
    final shouldProceed =
        await BlockUserDialog.show(
          context,
          user: user,
          isUserBlocked: isUserBlocked,
        ) ??
        false;

    if (shouldProceed && context.mounted) {
      context.read<UserBlockCubit>().toggleBlockUser(
        userId: user.id,
        isUserBlocked: isUserBlocked,
      );
    }
  }

  Future<void> _handleDeleteChat(BuildContext context) async {
    final confirmed = await ChatDeleteConfirmationDialog.show(context) ?? false;
    if (confirmed && context.mounted) {
      context.read<DeleteChatCubit>().deleteChats(itemOfferIds: [chatId]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      title: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(
            Routes.sellerProfileScreen,
            arguments: {'seller_id': user.id},
          );
        },
        child: Row(
          spacing: 20,
          children: [
            ProfileAvatar(
              src: user.profile ?? '',
              size: Size.square(40),
              errorImage: UserPlaceholderImage(
                placeholder: user.placeholder,
                size: Size.square(40),
              ),
            ),
            Expanded(child: Text(user.name, style: context.titleMedium)),
          ],
        ),
      ),
      actions: [
        PopupMenuButton(
          icon: Icon(AppIcons.dotsThreeVertical),
          itemBuilder: (context) {
            final isUserBlocked = context
                .read<ChatSessionCubit>()
                .isBlockedByMe;
            return [
              PopupMenuItem(
                onTap: () => _handleBlockUser(context, isUserBlocked),
                child: Row(
                  spacing: 8,
                  children: [
                    Icon(AppIcons.prohibit, size: 16),
                    Text(
                      isUserBlocked
                          ? "unblock".translate(context)
                          : "block".translate(context),
                    ),
                  ],
                ),
              ),

              PopupMenuItem(
                onTap: () => _handleDeleteChat(context),
                child: Row(
                  spacing: 8,
                  children: [
                    Icon(
                      AppIcons.trash,
                      size: 16,
                      color: context.colorScheme.error,
                    ),
                    Text(
                      "deleteChatTitle".translate(context),
                      style: context.bodyMedium.withColor(
                        context.colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ];
          },
        ),
        ListenableBuilder(
          listenable: selectionNotifier,
          builder: (context, _) {
            if (selectionNotifier.isNotEmpty) {
              return IconButton(
                onPressed: onDelete,
                icon: Icon(AppIcons.trash),
                tooltip: "delete".translate(context),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: _ItemBottomBar(
          item: item,
          isCurrentUserSeller: isCurrentUserSeller,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight * 2);
}

class _ItemBottomBar extends StatelessWidget {
  const _ItemBottomBar({required this.isCurrentUserSeller, required this.item});

  final ChatItem item;
  final bool isCurrentUserSeller;

  @override
  Widget build(BuildContext context) {
    final status = context.select<ItemStatusCubit, ItemStatus>(
      (c) => switch (c.state) {
        ItemStatusSuccess(status: final status) => status,
        _ => ItemStatus.unknown,
      },
    );

    return GestureDetector(
      onTap: () {
        if (status == ItemStatus.approved || isCurrentUserSeller) {
          Navigator.of(context).pushNamed(
            Routes.adDetailsScreen,
            arguments: {'item_id': item.id, 'is_my_item': isCurrentUserSeller},
          );
        }
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: context.theme.dividerColor)),
        ),
        child: Padding(
          padding: Constant.appContentPadding.copyWith(bottom: 8, top: 8),
          child: Row(
            spacing: 20,
            children: [
              ProfileAvatar(src: item.image, size: Size.square(40)),
              Expanded(
                child: Text(item.name, style: context.titleMedium, maxLines: 2),
              ),
              if (item.price.isNotNullAndNotEmpty)
                Text(
                  item.price!,
                  style: context.titleSmall.copyWith(
                    color: context.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
