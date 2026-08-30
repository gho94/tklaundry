import 'package:flutter/material.dart';

import '../tk_anchor_overlay.dart';
import 'tk_date_field.dart';
import 'tk_date_picker_panel.dart';

/// [TkDateField] + 필드 아래 [TkDatePickerPanel] Overlay.
class TkDatePickerField extends StatefulWidget {
  const TkDatePickerField({
    super.key,
    required this.label,
    required this.controller,
    required this.date,
    required this.onDateSelected,
    this.width = 150,
  });

  final String label;
  final TextEditingController controller;
  final DateTime date;
  final ValueChanged<DateTime> onDateSelected;
  final double width;

  @override
  State<TkDatePickerField> createState() => _TkDatePickerFieldState();
}

class _TkDatePickerFieldState extends State<TkDatePickerField> {
  final GlobalKey _fieldKey = GlobalKey();
  TkAnchorOverlayController? _overlay;
  bool _overlayReady = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_overlayReady) {
      _overlay = TkAnchorOverlayController(context);
      _overlayReady = true;
    }
  }

  @override
  void didUpdateWidget(covariant TkDatePickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.date != widget.date && (_overlay?.isShowing ?? false)) {
      _overlay?.refresh();
    }
  }

  @override
  void dispose() {
    _overlay?.dispose();
    super.dispose();
  }

  void _toggleOverlay() {
    final overlay = _overlay;
    if (overlay == null) return;

    if (overlay.isShowing) {
      overlay.hide();
      setState(() {});
      return;
    }

    _openOverlay();
  }

  void _openOverlay() {
    final overlay = _overlay!;

    overlay.show(
      offsetY: tkAnchorOverlayOffsetY(fieldKey: _fieldKey),
      panelBuilder: () => TkDatePickerPanel(
        initialDate: widget.date,
        onChanged: (date) {
          overlay.hide();
          widget.onDateSelected(date);
        },
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final overlay = _overlay;

    return tkAnchorOverlayField(
      layerLink: overlay?.layerLink ?? LayerLink(),
      tapRegionGroup: overlay?.tapRegionGroup ?? this,
      child: KeyedSubtree(
        key: _fieldKey,
        child: TkDateField(
          label: widget.label,
          controller: widget.controller,
          width: widget.width,
          onTap: _toggleOverlay,
        ),
      ),
    );
  }
}
