import 'dart:async';

import 'package:eClassify/features/auth/auth_module.dart';
import 'package:eClassify/features/auth/models/user.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/utils/auth_events.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AuthSessionState {}

class AuthSessionInitial extends AuthSessionState {}

enum SessionEndReason { userInitiated, expired }

class Unauthenticated extends AuthSessionState {
  Unauthenticated({this.reason = SessionEndReason.userInitiated});

  final SessionEndReason reason;
}

class Authenticated extends AuthSessionState {
  final User user;

  Authenticated({required this.user});
}

class ProfileIncomplete extends AuthSessionState {
  final User user;

  ProfileIncomplete({required this.user});
}

class AuthSessionCubit extends Cubit<AuthSessionState> {
  AuthSessionCubit() : super(AuthSessionInitial()) {
    checkCurrentSession();
    _authEventsSubscription = AuthEvents.sessionExpired.stream.listen(
      (_) => forceLogout(),
    );
  }

  late final StreamSubscription<void> _authEventsSubscription;

  void checkCurrentSession() {
    final user = AppSession.currentUser;
    if (user == null) {
      emit(Unauthenticated());
    } else if (!user.isProfileComplete) {
      emit(ProfileIncomplete(user: user));
    } else {
      emit(Authenticated(user: user));
    }
  }

  void updateSession(User user) {
    if (!user.isProfileComplete) {
      emit(ProfileIncomplete(user: user));
    } else {
      emit(Authenticated(user: user));
    }
  }

  void clearSession() async {
    await AuthModule.instance.localSessionService.clearLocalSession();
    emit(Unauthenticated());
  }

  Future<void> forceLogout() async {
    if (state is Unauthenticated) return;
    await AuthModule.instance.localSessionService.clearLocalSession();
    emit(Unauthenticated(reason: SessionEndReason.expired));
  }

  @override
  Future<void> close() {
    _authEventsSubscription.cancel();
    return super.close();
  }
}
