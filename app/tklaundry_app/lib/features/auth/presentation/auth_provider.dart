import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../code/presentation/code_provider.dart';
import '../data/auth_api.dart';
import '../data/auth_local_storage.dart';
import '../domain/auth_user.dart';

class AuthNotifier extends AsyncNotifier<AuthUser?> {
  late final AuthApi _authApi;
  late final AuthLocalStorage _storage;

  @override
  Future<AuthUser?> build() async {
    _authApi = AuthApi();
    _storage = AuthLocalStorage();

    final credentials = await _storage.readCredentials();
    if (credentials == null) return null;

    try {
      final result = await _authApi.login(
        userId: credentials.userId,
        password: credentials.password,
      );
      ref.read(codeProvider.notifier).setCodes(result.codes);
      return result.user;
    } on ApiException {
      await _storage.clear();
      return null;
    }
  }

  Future<void> login({
    required String userId,
    required String password,
    required bool autoLogin,
  }) async {
    try {
      final result = await _authApi.login(userId: userId, password: password);
      ref.read(codeProvider.notifier).setCodes(result.codes);
      if (autoLogin) {
        await _storage.save(userId: userId, password: password);
      } else {
        await _storage.clear();
      }
      state = AsyncData(result.user);
    } on ApiException {
      state = const AsyncData(null);
      rethrow;
    }
  }

  Future<void> signInFromRegister({
    required AuthUser user,
    required String password,
    required bool autoLogin,
  }) {
    return login(
      userId: user.userId,
      password: password,
      autoLogin: autoLogin,
    );
  }

  Future<void> logout() async {
    try {
      await _authApi.logout();
    } on ApiException {
      // 서버 세션 정리 실패해도 로컬 로그아웃은 진행
    }

    await _storage.clear();
    ref.read(codeProvider.notifier).clear();
    state = const AsyncData(null);
  }
}

final authProvider =
    AsyncNotifierProvider<AuthNotifier, AuthUser?>(AuthNotifier.new);
