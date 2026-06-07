import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class TkDropdownPanel extends StatelessWidget {
  const TkDropdownPanel({
    super.key,
    required this.width,
    this.maxHeight = 240,
    this.emptyMessage = '항목이 없습니다.',
    this.showAllOption = true,
    this.allSelected = false,
    this.onAllTap,
    this.allLabel = '전체',
    required this.children,
  });

  final double width;
  final double maxHeight;
  final String emptyMessage;
  final bool showAllOption;
  final bool allSelected;
  final VoidCallback? onAllTap;
  final String allLabel;
  final List<Widget> children;

  List<Widget> get _tiles {
    final tiles = <Widget>[];
    if (showAllOption && onAllTap != null) {
      tiles.add(
        TkDropdownTile(
          label: allLabel,
          selected: allSelected,
          onTap: onAllTap!,
        ),
      );
    }
    tiles.addAll(children);
    return tiles;
  }

  @override
  Widget build(BuildContext context) {
    final tiles = _tiles;

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(6),
      color: AppColors.surfaceCard,
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: width,
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.border),
        ),
        child: tiles.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  emptyMessage,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )
            : ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                primary: false,
                physics: const ClampingScrollPhysics(),
                itemCount: tiles.length,
                separatorBuilder: (_, _) => const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.border,
                ),
                itemBuilder: (_, index) => tiles[index],
              ),
      ),
    );
  }
}

class TkDropdownTile extends StatelessWidget {
  const TkDropdownTile({
    super.key,
    required this.label,
    this.subtitle,
    this.selected = false,
    required this.onTap,
  });

  final String label;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          color: AppColors.textPrimary,
        );
    final subtitleStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondary,
        );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (_) => onTap(),
        child: Container(
          color: selected ? AppColors.primary.withValues(alpha: 0.08) : null,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: titleStyle),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: subtitleStyle),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class TkDropdownOverlayController {
  TkDropdownOverlayController(this.context);

  final BuildContext context;
  final LayerLink layerLink = LayerLink();

  OverlayEntry? _entry;
  VoidCallback? _onHide;

  bool get isShowing => _entry != null;

  void show({
    required double width,
    required double offsetY,
    required Widget Function() panelBuilder,
    VoidCallback? onHide,
  }) {
    hide();
    _onHide = onHide;

    _entry = OverlayEntry(
      builder: (overlayContext) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: hide,
              ),
            ),
            CompositedTransformFollower(
              link: layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, offsetY),
              child: Material(
                color: Colors.transparent,
                child: panelBuilder(),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_entry!);
  }

  void refresh() => _entry?.markNeedsBuild();

  void hide() {
    if (_entry == null) return;
    _entry?.remove();
    _entry = null;
    _onHide?.call();
    _onHide = null;
  }

  void dispose() => hide();
}

InputDecoration tkDropdownDecoration({
  String? label,
  String? hint,
  String? errorText,
  bool compact = false,
  bool searchable = false,
  bool showClear = false,
  VoidCallback? onClear,
  bool enabled = true,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    errorText: errorText,
    isDense: compact,
    floatingLabelBehavior: FloatingLabelBehavior.auto,
    contentPadding: compact
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 10)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    prefixIcon: searchable
        ? const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Icon(Icons.search, size: 20),
          )
        : null,
    prefixIconConstraints: searchable ? const BoxConstraints(minWidth: 40, minHeight: 24) : null,
    suffixIcon: showClear
        ? IconButton(
            icon: const Icon(Icons.clear, size: 18),
            onPressed: enabled ? onClear : null,
          )
        : const Padding(
            padding: EdgeInsets.only(right: 4),
            child: Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
          ),
    suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 24),
  );
}

Widget tkDropdownAnchorField({
  required LayerLink layerLink,
  required Widget child,
}) {
  return CompositedTransformTarget(
    link: layerLink,
    child: child,
  );
}

double tkDropdownOffsetY({required GlobalKey fieldKey, required bool compact}) {
  final context = fieldKey.currentContext;
  if (context != null) {
    final box = context.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      return box.size.height + 4;
    }
  }
  return compact ? 40 : 52;
}
