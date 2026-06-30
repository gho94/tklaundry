import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/tk_combo_box.dart';
import '../../../shared/widgets/tk_primary_button.dart';
import '../../../shared/widgets/tk_text_field.dart';
import '../../code/domain/code.dart';
import '../../code/presentation/code_provider.dart';
import '../data/customer_api.dart';
import '../domain/customer.dart';

class CustomerRegisterDialog extends ConsumerStatefulWidget {
  const CustomerRegisterDialog({super.key, this.customer});

  final Customer? customer;

  bool get _isEdit => customer != null;

  static Future<bool?> showCreate(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => const CustomerRegisterDialog(),
    );
  }

  static Future<bool?> showEdit(BuildContext context, Customer customer) {
    return showDialog<bool>(
      context: context,
      builder: (_) => CustomerRegisterDialog(customer: customer),
    );
  }

  static Future<bool?> show(BuildContext context) => showCreate(context);

  @override
  ConsumerState<CustomerRegisterDialog> createState() =>
      _CustomerRegisterDialogState();
}

class _CustomerRegisterDialogState
    extends ConsumerState<CustomerRegisterDialog> {
  static const _aptCategoryCodeId = 'A10001';
  static const _floorCategoryCodeId = 'A10002';
  static const _roomCategoryCodeId = 'A10003';

  final _customerApi = CustomerApi();
  final _custNameController = TextEditingController();
  final _custPhoneController = TextEditingController();

  String? _aptCode;
  String? _buildingCode;
  String? _floorCode;
  String? _roomCode;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _traceId;

  bool get _isEdit => widget._isEdit;

  @override
  void initState() {
    super.initState();
    final customer = widget.customer;
    if (customer == null) return;

    _custNameController.text = customer.custName;
    _custPhoneController.text = customer.custPhone;
    _aptCode = _comboValue(customer.aptCode);
    _buildingCode = _comboValue(customer.buildingCode);
    _floorCode = _comboValue(customer.floorCode);
    _roomCode = _comboValue(customer.roomCode);
  }

  String? _comboValue(String code) => code.isEmpty ? null : code.trim();

  @override
  void dispose() {
    _custNameController.dispose();
    _custPhoneController.dispose();
    super.dispose();
  }

  List<TkComboItem<String>> _comboItems(Iterable<Code> codes) {
    final sorted = codes.toList()..sort((a, b) => a.codeId.compareTo(b.codeId));
    return [
      for (final code in sorted)
        TkComboItem(value: code.codeId.trim(), label: code.codeName),
    ];
  }

  List<TkComboItem<String>> _aptItems(List<Code> codes) {
    return _comboItems(
      codes.where((code) => code.pCodeId.trim() == _aptCategoryCodeId),
    );
  }

  List<TkComboItem<String>> _buildingItems(List<Code> codes) {
    final aptCode = _aptCode;
    if (aptCode == null) return const [];
    return _comboItems(
      codes.where((code) => code.pCodeId.trim() == aptCode),
    );
  }

  List<TkComboItem<String>> _floorItems(List<Code> codes) {
    return _comboItems(
      codes.where((code) => code.pCodeId.trim() == _floorCategoryCodeId),
    );
  }

  List<TkComboItem<String>> _roomItems(List<Code> codes) {
    return _comboItems(
      codes.where((code) => code.pCodeId.trim() == _roomCategoryCodeId),
    );
  }

  String? _codeName(String codeId, List<Code> codes) {
    for (final code in codes) {
      if (code.codeId.trim() == codeId) {
        return code.codeName;
      }
    }
    return null;
  }

  /// 레거시 `FrmCustomerInsert` 콤보 선택 시 `TxtCustName` 자동 조합과 동일.
  String _buildCustName(List<Code> codes) {
    final aptCode = _aptCode;
    if (aptCode == null) return '';

    final aptName = _codeName(aptCode, codes);
    if (aptName == null || aptName.isEmpty) return '';

    var name = aptName.length > 3
        ? aptName.substring(0, aptName.length - 3)
        : aptName;

    final buildingCode = _buildingCode;
    if (buildingCode != null) {
      final buildingName = _codeName(buildingCode, codes);
      if (buildingName != null && buildingName.length > 1) {
        name += ' ${buildingName.substring(0, buildingName.length - 1)}';
      }
    }

    final floorCode = _floorCode;
    if (floorCode != null) {
      final floorName = _codeName(floorCode, codes);
      if (floorName != null && floorName.length > 1) {
        name += '-${floorName.substring(0, floorName.length - 1)}';
      }
    }

    final roomCode = _roomCode;
    if (roomCode != null) {
      final roomName = _codeName(roomCode, codes);
      if (roomName != null && roomName.length > 1) {
        final roomNo = int.tryParse(
          roomName.substring(0, roomName.length - 1),
        );
        if (roomNo != null) {
          name += roomNo.toString().padLeft(2, '0');
        }
      }
    }

    return name;
  }

  void _syncCustName(List<Code> codes) {
    _custNameController.text = _buildCustName(codes);
  }

  void _onAptChanged(String? value, List<Code> codes) {
    setState(() {
      _aptCode = value;
      _buildingCode = null;
      _floorCode = null;
      _roomCode = null;
      _errorMessage = null;
      _syncCustName(codes);
    });
  }

  void _onBuildingChanged(String? value, List<Code> codes) {
    setState(() {
      _buildingCode = value;
      _floorCode = null;
      _roomCode = null;
      _errorMessage = null;
      _syncCustName(codes);
    });
  }

  void _onFloorChanged(String? value, List<Code> codes) {
    if (value != null && _buildingCode == null) {
      setState(() => _errorMessage = '동을 먼저 선택해 주세요.');
      return;
    }

    setState(() {
      _floorCode = value;
      _roomCode = null;
      _errorMessage = null;
      _syncCustName(codes);
    });
  }

  void _onRoomChanged(String? value, List<Code> codes) {
    if (value != null) {
      if (_buildingCode == null) {
        setState(() => _errorMessage = '동을 먼저 선택해 주세요.');
        return;
      }
      if (_floorCode == null) {
        setState(() => _errorMessage = '층을 먼저 선택해 주세요.');
        return;
      }
    }

    setState(() {
      _roomCode = value;
      _errorMessage = null;
      _syncCustName(codes);
    });
  }

  Future<void> _submit() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _traceId = null;
    });

    try {
      if (_isEdit) {
        await _customerApi.updateCustomer(
          custCode: widget.customer!.custCode,
          custName: _custNameController.text,
          aptCode: _aptCode,
          buildingCode: _buildingCode,
          floorCode: _floorCode,
          roomCode: _roomCode,
          custPhone: _custPhoneController.text,
        );
      } else {
        await _customerApi.registerCustomer(
          custName: _custNameController.text,
          aptCode: _aptCode,
          buildingCode: _buildingCode,
          floorCode: _floorCode,
          roomCode: _roomCode,
          custPhone: _custPhoneController.text,
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
    final codesAsync = ref.watch(codeProvider);

    return AlertDialog(
      title: Text(_isEdit ? '고객 수정' : '고객 등록'),
      content: SizedBox(
        width: 420,
        child: codesAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Text(
            error is ApiException
                ? error.message
                : '코드 정보를 불러오지 못했습니다.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.error,
                ),
          ),
          data: (codes) => _buildForm(codes),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
          child: const Text('취소'),
        ),
        TkPrimaryButton(
          label: _isEdit ? '저장' : '등록',
          isLoading: _isSubmitting,
          onPressed: _isSubmitting || codesAsync.isLoading ? null : _submit,
        ),
      ],
    );
  }

  Widget _buildForm(List<Code> codes) {
    final aptItems = _aptItems(codes);
    final buildingItems = _buildingItems(codes);
    final floorItems = _floorItems(codes);
    final roomItems = _roomItems(codes);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TkComboBox<String>(
                  label: '아파트',
                  items: aptItems,
                  value: _aptCode,
                  showAllOption: false,
                  enabled: aptItems.isNotEmpty,
                  onChanged: aptItems.isEmpty
                      ? null
                      : (value) => _onAptChanged(value, codes),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TkComboBox<String>(
                  label: '동',
                  items: buildingItems,
                  value: _buildingCode,
                  showAllOption: false,
                  enabled: _aptCode != null && buildingItems.isNotEmpty,
                  onChanged: _aptCode == null
                      ? null
                      : (value) => _onBuildingChanged(value, codes),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TkComboBox<String>(
                  label: '층',
                  items: floorItems,
                  value: _floorCode,
                  showAllOption: false,
                  enabled: _buildingCode != null && floorItems.isNotEmpty,
                  onChanged: _buildingCode == null
                      ? null
                      : (value) => _onFloorChanged(value, codes),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TkComboBox<String>(
                  label: '호',
                  items: roomItems,
                  value: _roomCode,
                  showAllOption: false,
                  enabled:
                      _buildingCode != null && _floorCode != null && roomItems.isNotEmpty,
                  onChanged: _buildingCode == null || _floorCode == null
                      ? null
                      : (value) => _onRoomChanged(value, codes),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TkTextField(
            controller: _custNameController,
            label: '이름',
            hint: '이름',
          ),
          const SizedBox(height: 12),
          TkTextField(
            controller: _custPhoneController,
            label: '전화번호',
            hint: '전화번호',
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
    );
  }
}
