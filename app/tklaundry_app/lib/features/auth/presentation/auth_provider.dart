import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/auth_user.dart';

class AuthNotifier extends Notifier<AuthUser?> {
  @override
  AuthUser? build() => null;

  /// API 연동 전 임시 로그인. 아이디만 비어 있지 않으면 통과.
  void login({required String userId}) {
    final id = userId.trim().isEmpty ? 'demo' : userId.trim();
    state = AuthUser(userId: id, userName: id);
  }

  void logout() {
    state = null;
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthUser?>(AuthNotifier.new);
