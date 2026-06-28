import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'tk_dropdown_panel.dart';

class TkComboItem<T> {
  const TkComboItem({required this.value, required this.label});

  final T value;
  final String label;
}

class TkComboBox<T> extends StatefulWidget {
  const TkComboBox({
    super.key,
    required this.items,
    this.value,
    this.label,
    this.hint,
    this.errorText,
    this.enabled = true,
    this.compact = false,
    this.showAllOption = true,
    this.onChanged,
  });

  final List<TkComboItem<T>> items;
  final T? value;
  final String? label;
  final String? hint;
  final String? errorText;
  final bool enabled;
  final bool compact;
  final bool showAllOption;
  final ValueChanged<T?>? onChanged;

  @override
  State<TkComboBox<T>> createState() => _TkComboBoxState<T>();
}

class _TkComboBoxState<T> extends State<TkComboBox<T>> {
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _fieldKey = GlobalKey();
  TkDropdownOverlayController? _overlay;
  bool _overlayReady = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_overlayReady) {
      _overlay = TkDropdownOverlayController(context);
      _overlayReady = true;
    }
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant TkComboBox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items || oldWidget.value != widget.value) {
      _overlay?.refresh();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _overlay?.dispose();
    super.dispose();
  }

  T? get _safeValue {
    if (widget.value == null) return null;
    return widget.items.any((item) => item.value == widget.value) ? widget.value : null;
  }

  TkComboItem<T>? get _selectedItem {
    final value = _safeValue;
    if (value == null) return null;
    for (final item in widget.items) {
      if (item.value == value) return item;
    }
    return null;
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      _overlay?.hide();
      setState(() {});
    }
  }

  void _select(T? value) {
    widget.onChanged?.call(value);
    _overlay?.hide();
    _focusNode.unfocus();
    setState(() {});
  }

  void _toggleOverlay() {
    if (!widget.enabled || _overlay == null) return;

    if (_overlay!.isShowing) {
      _overlay!.hide();
      _focusNode.unfocus();
      setState(() {});
      return;
    }

    _focusNode.requestFocus();
    _openOverlay();
  }

  void _openOverlay() {
    final overlay = _overlay!;
    final renderBox = _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    final width = renderBox?.size.width ?? 240;

    overlay.show(
      width: width,
      offsetY: tkDropdownOffsetY(fieldKey: _fieldKey, compact: widget.compact),
      panelBuilder: () => TkDropdownPanel(
        width: width,
        showAllOption: widget.showAllOption,
        allSelected: _safeValue == null,
        onAllTap: () => _select(null),
        children: [
          for (final item in widget.items)
            TkDropdownTile(
              label: item.label,
              selected: item.value == _safeValue,
              onTap: () => _select(item.value),
            ),
        ],
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedItem;
    final overlay = _overlay;
    final isOpen = overlay?.isShowing ?? false;
    final displayText = selected?.label ?? '';

    return tkDropdownAnchorField(
      layerLink: overlay?.layerLink ?? LayerLink(),
      child: Focus(
        key: _fieldKey,
        focusNode: _focusNode,
        child: InputDecorator(
          isFocused: _focusNode.hasFocus || isOpen,
          isEmpty: displayText.isEmpty,
          decoration: tkDropdownDecoration(
            label: widget.label,
            hint: widget.hint,
            errorText: widget.errorText,
            compact: widget.compact,
            enabled: widget.enabled,
          ),
          child: InkWell(
            onTap: widget.enabled ? _toggleOverlay : null,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                displayText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TkGridComboBox<T> extends StatelessWidget {
  const TkGridComboBox({
    super.key,
    required this.items,
    this.value,
    this.hint = '선택',
    this.enabled = true,
    this.showAllOption = true,
    this.onChanged,
  });

  final List<TkComboItem<T>> items;
  final T? value;
  final String? hint;
  final bool enabled;
  final bool showAllOption;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TkComboBox<T>(
        items: items,
        value: value,
        hint: hint,
        compact: true,
        showAllOption: showAllOption,
        enabled: enabled,
        onChanged: onChanged,
      ),
    );
  }
}
