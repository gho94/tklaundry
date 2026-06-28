import 'package:flutter/material.dart';

import 'tk_dropdown_panel.dart';

class TkLookupItem<T> {
  const TkLookupItem({
    required this.value,
    required this.label,
    this.subtitle,
  });

  final T value;
  final String label;
  final String? subtitle;

  bool matches(String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    if (label.toLowerCase().contains(q)) return true;
    if (subtitle != null && subtitle!.toLowerCase().contains(q)) return true;
    return false;
  }
}

class TkLookupField<T> extends StatefulWidget {
  const TkLookupField({
    super.key,
    required this.items,
    this.value,
    this.label,
    this.hint = '코드 또는 이름 검색',
    this.errorText,
    this.enabled = true,
    this.showAllOption = true,
    this.onChanged,
  });

  final List<TkLookupItem<T>> items;
  final T? value;
  final String? label;
  final String? hint;
  final String? errorText;
  final bool enabled;
  final bool showAllOption;
  final ValueChanged<T?>? onChanged;

  @override
  State<TkLookupField<T>> createState() => _TkLookupFieldState<T>();
}

class _TkLookupFieldState<T> extends State<TkLookupField<T>> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  final GlobalKey _fieldKey = GlobalKey();
  TkDropdownOverlayController? _overlay;
  bool _overlayReady = false;

  String _filterQuery = '';
  bool _ignoreFocusLoss = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _labelForValue(widget.value));
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChanged);
    _controller.addListener(_onTextChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_overlayReady) {
      _overlay = TkDropdownOverlayController(context);
      _overlayReady = true;
    }
  }

  @override
  void didUpdateWidget(covariant TkLookupField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _ignoreFocusLoss = false;
      final label = _labelForValue(widget.value);
      if (_controller.text != label) {
        _controller.text = label;
      }
    }
    if (oldWidget.items != widget.items && _overlay?.isShowing == true) {
      _overlay?.refresh();
    }
  }

  @override
  void dispose() {
    _overlay?.dispose();
    _focusNode.removeListener(_onFocusChanged);
    _controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  String _labelForValue(T? value) {
    if (value == null) return '';
    for (final item in widget.items) {
      if (item.value == value) return item.label;
    }
    return '';
  }

  List<TkLookupItem<T>> get _filteredItems {
    return widget.items.where((item) => item.matches(_filterQuery)).toList();
  }

  void _onFocusChanged() {
    if (_ignoreFocusLoss) return;

    if (_focusNode.hasFocus) {
      _filterQuery = '';
      _openOverlay();
    } else if (_overlay?.isShowing != true) {
      _filterQuery = '';
      _syncTextToSelection();
      setState(() {});
    }
  }

  void _onTextChanged() {
    if (_ignoreFocusLoss) return;

    _filterQuery = _controller.text;
    if (_focusNode.hasFocus) {
      if (_overlay?.isShowing != true) {
        _openOverlay();
      } else {
        _overlay?.refresh();
      }
    }
    setState(() {});
  }

  void _onOverlayDismissed() {
    if (_ignoreFocusLoss) return;

    _filterQuery = '';
    _syncTextToSelection();
    _focusNode.unfocus();
    if (mounted) setState(() {});
  }

  void _syncTextToSelection() {
    final expected = _labelForValue(widget.value);
    if (_controller.text != expected) {
      _controller.text = expected;
    }
  }

  void _applySelection(T? value, {required String displayText}) {
    _ignoreFocusLoss = true;
    _filterQuery = '';
    _overlay?.hide();

    _controller.text = displayText;
    widget.onChanged?.call(value);
    _focusNode.unfocus();
    setState(() {});
  }

  void _selectItem(TkLookupItem<T> item) {
    _applySelection(item.value, displayText: item.label);
  }

  void _selectAll() {
    _applySelection(null, displayText: '');
  }

  void _clearSelection() {
    _selectAll();
  }

  void _openOverlay() {
    final overlay = _overlay;
    if (overlay == null || !mounted) return;

    final renderBox = _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    final width = renderBox?.size.width ?? 300;

    overlay.show(
      width: width,
      offsetY: tkDropdownOffsetY(fieldKey: _fieldKey, compact: false),
      panelBuilder: _buildPanel,
      onHide: _onOverlayDismissed,
    );
    setState(() {});
  }

  Widget _buildPanel() {
    final width = (_fieldKey.currentContext?.findRenderObject() as RenderBox?)?.size.width ?? 300;

    return TkDropdownPanel(
      width: width,
      showAllOption: widget.showAllOption,
      allSelected: widget.value == null,
      onAllTap: _selectAll,
      emptyMessage: '검색 결과가 없습니다.',
      children: [
        for (final item in _filteredItems)
          TkDropdownTile(
            label: item.label,
            subtitle: item.subtitle,
            selected: item.value == widget.value,
            onTap: () => _selectItem(item),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final overlay = _overlay;

    return tkDropdownAnchorField(
      layerLink: overlay?.layerLink ?? LayerLink(),
      child: TextField(
        key: _fieldKey,
        controller: _controller,
        focusNode: _focusNode,
        enabled: widget.enabled,
        onTap: () {
          _filterQuery = '';
          _focusNode.requestFocus();
        },
        onTapOutside: (_) {
          if (_overlay?.isShowing != true) {
            _focusNode.unfocus();
          }
        },
        decoration: tkDropdownDecoration(
          label: widget.label,
          hint: widget.hint,
          errorText: widget.errorText,
          searchable: true,
          showClear: widget.value != null,
          onClear: _clearSelection,
          enabled: widget.enabled,
        ),
      ),
    );
  }
}
