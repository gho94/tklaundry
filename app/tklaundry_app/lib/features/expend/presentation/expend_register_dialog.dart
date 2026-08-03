import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/code_constants.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/utils/tk_format.dart';
import '../../../shared/widgets/tk_combo_box.dart';
import '../../../shared/widgets/tk_primary_button.dart';
import '../../../shared/widgets/tk_text_field.dart';
import '../../code/domain/code.dart';
import '../../code/presentation/code_list_extensions.dart';
import '../../code/presentation/code_provider.dart';
import '../data/expend_api.dart';
import '../domain/expend.dart';

class ExpendRegisterDialog extends ConsumerStatefulWidget {
  const ExpendRegisterDialog({super.key, this.expend});

  final Expend? expend;

  bool get _isEdit => expend != null;

  static Future<bool?> showCreate(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => const ExpendRegisterDialog(),
    );
  }

  static Future<bool?> showEdit(BuildContext context, Expend expend) {
    return showDialog<bool>(
      context: context,
      builder: (_) => ExpendRegisterDialog(expend: expend),
    );
  }

  @override
  ConsumerState<ExpendRegisterDialog> createState() =>
      _ExpendRegisterDialogState();
}

class _ExpendRegisterDialogState extends ConsumerState<ExpendRegisterDialog> {
  final _expendApi = ExpendApi();
  final _costController = TextEditingController();
  final _remarkController = TextEditingController();
  late final TextEditingController _expendDateController;

  late DateTime _expendDate;
  String? _expendCode;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _traceId;

  bool get _isEdit => widget._isEdit;

  @override
  void initState() {
    super.initState();
    final expend = widget.expend;
    if (expend != null) {
      final parsed = DateTime.tryParse(expend.expendDate);
      _expendDate = parsed != null
          ? DateTime(parsed.year, parsed.month, parsed.day)
          : DateTime.now();
      _expendCode =
          expend.expendCode.isEmpty ? null : expend.expendCode.trim();
      _costController.text = expend.cost.toString();
      _remarkController.text = expend.remark;
    } else {
      final today = DateTime.now();
      _expendDate = DateTime(today.year, today.month, today.day);
    }
    _expendDateController =
        TextEditingController(text: _expendDate.toApiDate());
  }

  @override
  void dispose() {
    _costController.dispose();
    _remarkController.dispose();
    _expendDateController.dispose();
    super.dispose();
  }

  List<TkComboItem<String>> _expendTypeItems(List<Code> codes) {
    return codes.comboItems(CodeConstants.expendType);
  }

  Future<void> _pickExpendDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expendDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;

    setState(() {
      _expendDate = DateTime(picked.year, picked.month, picked.day);
      _expendDateController.text = _expendDate.toApiDate();
    });
  }

  Future<void> _submit() async {
    final expendCode = _expendCode;
    if (expendCode == null || expendCode.isEmpty) {
      setState(() => _errorMessage = '지출 종류를 선택해 주세요.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _traceId = null;
    });

    final cost = int.tryParse(_costController.text.trim()) ?? 0;
    final remark = _remarkController.text.trim();

    try {
      if (_isEdit) {
        await _expendApi.updateExpend(
          idx: widget.expend!.idx,
          expendDate: _expendDate,
          expendCode: expendCode,
          cost: cost,
          remark: remark,
        );
      } else {
        await _expendApi.registerExpend(
          expendDate: _expendDate,
          expendCode: expendCode,
          cost: cost,
          remark: remark,
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

  @override
  Widget build(BuildContext context) {
    final codes = ref.watch(codeProvider);
    final expendTypeItems = _expendTypeItems(codes);

    return AlertDialog(
      title: Text(_isEdit ? '지출 수정' : '지출 등록'),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickExpendDate,
                child: AbsorbPointer(
                  child: TkTextField(
                    label: '지출 일자',
                    readOnly: true,
                    controller: _expendDateController,
                    suffixIcon:
                        const Icon(Icons.calendar_today_outlined, size: 18),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TkComboBox<String>(
                label: '지출 종류',
                items: expendTypeItems,
                value: _expendCode,
                enabled: expendTypeItems.isNotEmpty,
                showAllOption: false,
                onChanged: expendTypeItems.isEmpty
                    ? null
                    : (value) {
                        setState(() {
                          _expendCode = value;
                          _errorMessage = null;
                        });
                      },
              ),
              const SizedBox(height: 12),
              TkTextField(
                controller: _costController,
                label: '지출 비용',
                hint: '지출 비용',
              ),
              const SizedBox(height: 12),
              TkTextField(
                controller: _remarkController,
                label: '비고',
                hint: '비고',
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
      ),
      actions: [
        TextButton(
          onPressed:
              _isSubmitting ? null : () => Navigator.of(context).pop(false),
          child: const Text('취소'),
        ),
        TkPrimaryButton(
          label: _isEdit ? '저장' : '등록',
          isLoading: _isSubmitting,
          onPressed: _isSubmitting ? null : _submit,
        ),
      ],
    );
  }
}
