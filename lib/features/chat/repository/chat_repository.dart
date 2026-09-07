import 'dart:developer';

import 'package:eClassify/features/chat/models/chat_message.dart';
import 'package:eClassify/core/models/data_output.dart';
import 'package:eClassify/core/network/api.dart';
import 'package:eClassify/core/utils/json_helper.dart';

class ChatRepository {
  ChatRepository._internal();

  static final ChatRepository _instance = ChatRepository._internal();

  static ChatRepository get instance => _instance;

  /// Fetches messages for a specific chat (item offer).
  Future<DataOutput<ChatMessage>> getMessages({
    required int chatId,
    int page = 1,
  }) async {
    try {
      final response = await Api.get(
        url: ApiEndpoints.chatMessages,
        queryParameters: {ApiParams.itemOfferId: chatId, ApiParams.page: page},
      );

      final messages = JsonHelper.parseList(
        response['data']['data'] as List?,
        ChatMessage.parse,
      );
      final total = response['data']['total'] as int;

      return DataOutput(total: total, modelList: messages);
    } on Exception catch (e, stack) {
      log(e.toString(), name: 'getMessages');
      log('$stack', name: 'getMessages');
      rethrow;
    }
  }

  /// Sends a message to a chat.
  /// This method uses the message's [toJson] implementation to generate API parameters,
  /// allowing for a clean, model-driven interface.
  /// [onProgress] captures multipart upload progress for media messages.
  Future<ChatMessage> sendMessage(
    ChatMessage message, {
    void Function(double progress)? onProgress,
  }) async {
    try {
      final response = await Api.post(
        url: ApiEndpoints.sendMessage,
        parameter: message.toJson,
        onSendProgress: (sent, total) {
          if (onProgress != null && total > 0) {
            onProgress(sent / total);
          }
        },
        catchApiError: false,
      );

      if (response['error'] == true) {
        if (response['data']?['key'] == 'blocked_by_other_user') {
          throw ApiException('blocked_by_other_user');
        } else {
          throw ApiException(response['message'].toString());
        }
      }
      return ChatMessage.parse(response['data'] as Map<String, dynamic>);
    } on Exception catch (e, stack) {
      log(e.toString(), name: 'sendMessage');
      log('$stack', name: 'sendMessage');
      rethrow;
    }
  }

  /// Toggles blocking/unblocking a user.
  Future<void> toggleBlockUser({
    required int userId,
    bool isUserBlocked = false,
  }) async {
    try {
      final parameters = {ApiParams.blockedUserId: userId};
      final endpoint = isUserBlocked
          ? ApiEndpoints.unBlockUser
          : ApiEndpoints.blockUser;
      await Api.post(url: endpoint, parameter: parameters);
    } on Exception catch (e, stack) {
      log(e.toString(), name: 'toggleBlockUser');
      log('$stack', name: 'toggleBlockUser');
    }
  }

  /// Deletes multiple messages by their IDs.
  Future<void> deleteMessages(int chatId, List<int> ids) async {
    try {
      final parameters = {
        ApiParams.itemOfferId: chatId,
        ApiParams.messageIds: ids,
      };
      await Api.post(
        url: ApiEndpoints.deleteChatMessages,
        parameter: parameters,
      );
    } on Exception catch (e, stack) {
      log(e.toString(), name: 'deleteMessages');
      log('$stack', name: 'deleteMessages');
      rethrow;
    }
  }
}
