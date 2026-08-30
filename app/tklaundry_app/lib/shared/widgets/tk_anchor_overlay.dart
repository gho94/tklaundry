import 'package:flutter/material.dart';

/// 필드 아래 패널을 띄우는 공통 Overlay (콤보 · lookup · 날짜).
class TkAnchorOverlayController {
  TkAnchorOverlayController(this.context);

  final BuildContext context;
  final LayerLink layerLink = LayerLink();

  /// 앵커 필드와 패널을 같은 그룹으로 묶어, 바깥 탭만 닫고
  /// 다른 필드의 클릭은 가로채지 않는다.
  final Object tapRegionGroup = Object();

  OverlayEntry? _entry;
  VoidCallback? _onHide;

  bool get isShowing => _entry != null;

  void show({
    required double offsetY,
    required Widget Function() panelBuilder,
    VoidCallback? onHide,
    bool wrapMaterial = false,
  }) {
    hide();
    _onHide = onHide;

    _entry = OverlayEntry(
      builder: (_) {
        Widget panel = panelBuilder();
        if (wrapMaterial) {
          panel = Material(
            color: Colors.transparent,
            child: panel,
          );
        }

        // Overlay는 자식에게 화면 전체 loose constraints를 준다.
        // Align(width/heightFactor: 1)로 패널 콘텐츠 크기로 줄이지 않으면
        // Material이 아래로 크게 늘어나 흰 영역·클릭 먹통이 된다.
        return CompositedTransformFollower(
          link: layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, offsetY),
          child: TapRegion(
            groupId: tapRegionGroup,
            onTapOutside: (_) => hide(),
            child: Align(
              alignment: Alignment.topLeft,
              widthFactor: 1,
              heightFactor: 1,
              child: panel,
            ),
          ),
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

Widget tkAnchorOverlayField({
  required LayerLink layerLink,
  required Object tapRegionGroup,
  required Widget child,
}) {
  return CompositedTransformTarget(
    link: layerLink,
    child: TapRegion(
      groupId: tapRegionGroup,
      child: child,
    ),
  );
}

double tkAnchorOverlayOffsetY({
  required GlobalKey fieldKey,
  bool compact = false,
}) {
  final context = fieldKey.currentContext;
  if (context != null) {
    final box = context.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      return box.size.height + 4;
    }
  }
  return compact ? 40 : 52;
}
