import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eClassify/features/auth/models/auth_provider.dart';
import 'package:eClassify/features/auth/models/auth_result.dart';
import 'package:eClassify/features/auth/models/user.dart';
import 'package:eClassify/features/auth/services/local_session_service.dart';
import 'package:eClassify/features/auth/services/phone_auth_service.dart';
import 'package:eClassify/core/models/contact.dart';
import 'package:eClassify/core/network/api.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthRepository {
  AuthRepository({
    required this.phoneAuthService,
    required this.localSessionService,
  });

  final PhoneAuthService phoneAuthService;
  final LocalSessionService localSessionService;

  Future<String> get _getFcmToken async {
    try {
      return await FirebaseMessaging.instance.getToken() ?? '';
    } on Exception catch (e, st) {
      Log.error('Failed to get FCM token', e, st);
      return '';
    }
  }

  /// Checks whether a Firebase social-login account is already registered
  /// on the backend. Used to gate first-time social sign-ins behind terms
  /// acceptance before [registerOrLoginRemote] creates the account.
  Future<bool> checkSocialUserExists({required String firebaseId}) async {
    final response = await Api.get(
      url: ApiEndpoints.userExists,
      queryParameters: {ApiParams.firebaseId: firebaseId},
      catchApiError: false,
    );
    return response['data']?['user_exists'] == true || response['data'] == true;
  }

  Future<AuthResult> registerOrLoginRemote({
    required String firebaseId,
    required AuthProvider provider,
    Contact? contact,
    String? email,
    String? name,
    String? password,
    bool isLogin = true,
  }) async {
    final response = await Api.post(
      url: ApiEndpoints.login,
      parameter: {
        ApiParams.mobile: ?contact?.number,
        ApiParams.firebaseId: firebaseId,
        ApiParams.type: provider.raw,
        ApiParams.platformType: Platform.isAndroid ? "android" : "ios",
        ApiParams.fcmId: await _getFcmToken,
        ApiParams.email: ?email,
        ApiParams.name: ?name,
        ApiParams.countryCode: ?contact?.callingCode,
        ApiParams.regionCode: ?contact?.regionCode,
        'password': ?password,
        'is_login': isLogin ? '1' : '0',
      },
    );

    final user = User.fromJson(response['data']);
    return (token: response['token'] as String, user: user);
  }

  Future<void> resetPasswordWithPhone({
    required Contact contact,
    required String newPassword,
    required String jwtToken,
  }) async {
    await Api.post(
      url: ApiEndpoints.resetPassword,
      parameter: {
        'number': contact.number,
        'country_code': contact.callingCode,
        'new_password': newPassword,
      },
      options: Options(headers: {'Authorization': 'Bearer $jwtToken'}),
    );
  }

  Future<AuthResult> loginWithPhonePassword({
    required Contact contact,
    required String password,
  }) async {
    return phoneAuthService.signInWithPhonePassword(
      contact: contact,
      password: password,
      fcmId: await _getFcmToken,
    );
  }

  Future<void> remoteLogout({required String fcmToken}) async {
    await Api.post(url: ApiEndpoints.logout, parameter: {'fcm_token': fcmToken});
  }

  Future<void> deleteRemoteUser() async {
    await Api.delete(url: ApiEndpoints.deleteUser);
  }
}
