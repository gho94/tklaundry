import 'package:flutter/material.dart';

import '../tk_dropdown_panel.dart';
import 'tk_lookup_item.dart';
import 'tk_lookup_panel.dart';

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
    this.primaryColumnLabel = '항목',
    this.secondaryColumnLabel,
    this.panelMinWidth = 320,
    this.onChanged,
  });

  final List<TkLookupItem<T>> items;
  final T? value;
  final String? label;
  final String? hint;
  final String? errorText;
  final bool enabled;
  final bool showAllOption;

  /// [secondaryColumnLabel]이 있으면 2열 그리드 lookup 패널 사용.
  final String primaryColumnLabel;
  final String? secondaryColumnLabel;
  final double panelMinWidth;
  final ValueChanged<T?>? onChanged;

  bool get _useGridPanel => secondaryColumnLabel != null;

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
      _filterQuery = _controller.text;
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

  double _panelWidth(double fieldWidth) {
    return fieldWidth < widget.panelMinWidth ? widget.panelMinWidth : fieldWidth;
  }

  void _openOverlay() {
    final overlay = _overlay;
    if (overlay == null || !mounted) return;

    final renderBox = _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    final fieldWidth = renderBox?.size.width ?? 300;

    overlay.show(
      width: _panelWidth(fieldWidth),
      offsetY: tkDropdownOffsetY(fieldKey: _fieldKey, compact: false),
      panelBuilder: _buildPanel,
      onHide: _onOverlayDismissed,
    );
    setState(() {});
  }

  Widget _buildPanel() {
    final renderBox = _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    final fieldWidth = renderBox?.size.width ?? 300;
    final panelWidth = _panelWidth(fieldWidth);
    final filtered = _filteredItems;

    if (widget._useGridPanel) {
      return TkLookupGridPanel<T>(
        width: panelWidth,
        items: filtered,
        query: _filterQuery,
        selectedValue: widget.value,
        primaryColumnLabel: widget.primaryColumnLabel,
        secondaryColumnLabel: widget.secondaryColumnLabel!,
        showAllOption: widget.showAllOption,
        allSelected: widget.value == null,
        onAllTap: _selectAll,
        onItemTap: _selectItem,
      );
    }

    return TkDropdownPanel(
      width: panelWidth,
      showAllOption: widget.showAllOption,
      allSelected: widget.value == null,
      onAllTap: _selectAll,
      emptyMessage: '검색 결과가 없습니다.',
      children: [
        for (final item in filtered)
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
      tapRegionGroup: overlay?.tapRegionGroup ?? this,
      child: TextField(
        key: _fieldKey,
        controller: _controller,
        focusNode: _focusNode,
        enabled: widget.enabled,
        onTap: () {
          _filterQuery = _controller.text;
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
