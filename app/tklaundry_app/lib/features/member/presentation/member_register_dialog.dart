import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/tk_combo_box.dart';
import '../../../shared/widgets/tk_primary_button.dart';
import '../../../shared/widgets/tk_text_field.dart';
import '../../auth/data/auth_api.dart';
import '../../auth/presentation/auth_provider.dart';
import '../data/member_api.dart';
import '../domain/member.dart';

class MemberRegisterDialog extends ConsumerStatefulWidget {
  const MemberRegisterDialog({
    super.key,
    this.member,
    this.signInAfterRegister = false,
    this.autoLogin = false,
  });

  final Member? member;
  final bool signInAfterRegister;
  final bool autoLogin;

  bool get _isEdit => member != null;

  static Future<bool?> showCreate(
    BuildContext context, {
    bool signInAfterRegister = false,
    bool autoLogin = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => MemberRegisterDialog(
        signInAfterRegister: signInAfterRegister,
        autoLogin: autoLogin,
      ),
    );
  }

  static Future<bool?> showEdit(BuildContext context, Member member) {
    return showDialog<bool>(
      context: context,
      builder: (_) => MemberRegisterDialog(member: member),
    );
  }

  static Future<bool?> show(
    BuildContext context, {
    bool signInAfterRegister = false,
    bool autoLogin = false,
  }) =>
      showCreate(
        context,
        signInAfterRegister: signInAfterRegister,
        autoLogin: autoLogin,
      );

  @override
  ConsumerState<MemberRegisterDialog> createState() =>
      _MemberRegisterDialogState();
}

class _MemberRegisterDialogState extends ConsumerState<MemberRegisterDialog> {
  final _authApi = AuthApi();
  final _memberApi = MemberApi();
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _userNameController = TextEditingController();

  static const _useYnItems = [
    TkComboItem(value: 'Y', label: 'Y'),
    TkComboItem(value: 'N', label: 'N'),
  ];

  String _useYn = 'Y';
  bool _isCheckingId = false;
  bool _isSubmitting = false;
  bool _idChecked = false;
  bool _idAvailable = false;
  String? _userIdCheckMessage;
  Color? _userIdCheckColor;
  String? _errorMessage;
  String? _traceId;

  @override
  void initState() {
    super.initState();
    final member = widget.member;
    if (member == null) return;

    _userIdController.text = member.userId;
    _userNameController.text = member.userName;
    _useYn = member.useYn == 'N' ? 'N' : 'Y';
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    _userNameController.dispose();
    super.dispose();
  }

  void _resetUserIdCheck() {
    setState(() {
      _idChecked = false;
      _idAvailable = false;
      _userIdCheckMessage = null;
      _userIdCheckColor = null;
    });
  }

  Future<void> _checkUserId() async {
    final userId = _userIdController.text.trim();
    if (userId.isEmpty) {
      setState(() {
        _userIdCheckMessage = '아이디를 입력해 주세요.';
        _userIdCheckColor = AppColors.error;
        _idChecked = false;
      });
      return;
    }

    setState(() {
      _isCheckingId = true;
      _userIdCheckMessage = null;
      _errorMessage = null;
      _traceId = null;
    });

    try {
      final exists = await _memberApi.existsUserId(userId);
      if (!mounted) return;
      setState(() {
        _idChecked = true;
        _idAvailable = !exists;
        _userIdCheckMessage =
            exists ? '이미 사용 중인 아이디입니다.' : '사용 가능한 아이디입니다.';
        _userIdCheckColor = exists ? AppColors.error : AppColors.primary;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _idChecked = false;
        _userIdCheckMessage = error.message;
        _userIdCheckColor = AppColors.error;
      });
    } finally {
      if (mounted) {
        setState(() => _isCheckingId = false);
      }
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (widget._isEdit) {
      await _submitEdit();
    } else {
      await _submitCreate();
    }
  }

  Future<void> _submitCreate() async {
    final userId = _userIdController.text.trim();
    final password = _passwordController.text;
    final userName = _userNameController.text.trim();

    if (userId.isEmpty || password.isEmpty || userName.isEmpty) {
      setState(() {
        _errorMessage = '아이디, 비밀번호, 이름을 입력해 주세요.';
        _traceId = null;
      });
      return;
    }

    if (!_idChecked || !_idAvailable) {
      setState(() {
        _errorMessage = '아이디 중복 확인을 해 주세요.';
        _traceId = null;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _traceId = null;
    });

    try {
      final user = await _authApi.register(
        userId: userId,
        password: password,
        userName: userName,
        useYn: _useYn,
      );
      if (widget.signInAfterRegister) {
        await ref.read(authProvider.notifier).signInFromRegister(
              user: user,
              password: password,
              autoLogin: widget.autoLogin,
            );
      }
      if (!mounted) return;

      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.message;
        _traceId = error.traceId;
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _submitEdit() async {
    final userName = _userNameController.text.trim();
    final password = _passwordController.text;

    if (userName.isEmpty) {
      setState(() {
        _errorMessage = '이름을 입력해 주세요.';
        _traceId = null;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _traceId = null;
    });

    try {
      await _memberApi.updateMember(
        userId: widget.member!.userId,
        userName: userName,
        useYn: _useYn,
        password: password.isEmpty ? null : password,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.message;
        _traceId = error.traceId;
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget._isEdit;
    final isBusy = _isCheckingId || _isSubmitting;

    return AlertDialog(
      title: Text(isEdit ? '회원 수정' : '회원 등록'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isEdit)
              TkTextField(
                controller: _userIdController,
                label: '아이디',
                readOnly: true,
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TkTextField(
                      controller: _userIdController,
                      label: '아이디',
                      hint: '아이디',
                      onChanged: (_) => _resetUserIdCheck(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TkPrimaryButton(
                      label: '중복 확인',
                      variant: TkButtonVariant.outline,
                      isLoading: _isCheckingId,
                      onPressed: isBusy ? null : _checkUserId,
                    ),
                  ),
                ],
              ),
            if (!isEdit && _userIdCheckMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _userIdCheckMessage!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _userIdCheckColor,
                    ),
              ),
            ],
            const SizedBox(height: 12),
            TkTextField(
              controller: _passwordController,
              label: '비밀번호',
              hint: isEdit ? '변경 시에만 입력' : '비밀번호',
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TkTextField(
              controller: _userNameController,
              label: '이름',
              hint: '이름',
            ),
            const SizedBox(height: 12),
            TkComboBox<String>(
              items: _useYnItems,
              value: _useYn,
              label: '사용여부',
              showAllOption: false,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _useYn = value);
                }
              },
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.error,
                      height: 1.4,
                    ),
              ),
            ],
            if (_traceId != null) ...[
              const SizedBox(height: 8),
              Text(
                'traceId: $_traceId',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isBusy ? null : () => Navigator.of(context).pop(false),
          child: const Text('취소'),
        ),
        TkPrimaryButton(
          label: isEdit ? '저장' : '등록',
          isLoading: _isSubmitting,
          onPressed: isBusy ? null : _submit,
        ),
      ],
    );
  }
}
