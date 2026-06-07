import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/tk_primary_button.dart';
import '../../../shared/widgets/tk_text_field.dart';
import 'auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    ref.read(authProvider.notifier).login(
          userId: _userIdController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '태강세탁소',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '로그인',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 32),
                  TkTextField(
                    controller: _userIdController,
                    label: '아이디',
                    hint: '아이디를 입력하세요',
                    autofocus: true,
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 12),
                  TkTextField(
                    controller: _passwordController,
                    label: '비밀번호',
                    hint: '비밀번호 (임시 · 검증 없음)',
                    obscureText: true,
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 24),
                  TkPrimaryButton(
                    label: '로그인',
                    icon: Icons.login,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'API 연동 전입니다. 아이디 없이 로그인 버튼만 눌러도 이동합니다.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
