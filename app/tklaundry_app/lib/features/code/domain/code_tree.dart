import 'code.dart';

class CodeTreeNode {
  const CodeTreeNode({
    required this.code,
    required this.children,
  });

  final Code code;
  final List<CodeTreeNode> children;

  bool get hasChildren => children.isNotEmpty;
}

/// flat 목록을 `pCodeId` 기준 트리로 조립한다. 루트 부모는 `ROOT`(대소문자·공백 무시).
List<CodeTreeNode> buildCodeTree(List<Code> codes) {
  final byParent = <String, List<Code>>{};
  for (final code in codes) {
    final parentKey = code.pCodeId.trim();
    byParent.putIfAbsent(parentKey, () => []).add(code);
  }

  for (final list in byParent.values) {
    list.sort((a, b) => a.codeId.compareTo(b.codeId));
  }

  List<CodeTreeNode> buildChildren(String parentCodeId) {
    final children = byParent[parentCodeId] ?? const [];
    return [
      for (final child in children)
        CodeTreeNode(
          code: child,
          children: buildChildren(child.codeId),
        ),
    ];
  }

  final rootKey = byParent.keys.firstWhere(
    Code.isRootParent,
    orElse: () => 'ROOT',
  );

  return buildChildren(rootKey);
}

class CodeTreeRow {
  const CodeTreeRow({
    required this.node,
    required this.depth,
  });

  final CodeTreeNode node;
  final int depth;
}

/// 펼침 상태에 따라 화면에 보일 행만 평탄화한다.
List<CodeTreeRow> flattenCodeTree(
  List<CodeTreeNode> roots, {
  required Set<String> expandedCodeIds,
}) {
  final rows = <CodeTreeRow>[];

  void visit(CodeTreeNode node, int depth) {
    rows.add(CodeTreeRow(node: node, depth: depth));
    if (!node.hasChildren || !expandedCodeIds.contains(node.code.codeId)) {
      return;
    }
    for (final child in node.children) {
      visit(child, depth + 1);
    }
  }

  for (final root in roots) {
    visit(root, 0);
  }

  return rows;
}

int codeDepth(String codeId, List<Code> codes) {
  final byId = {for (final code in codes) code.codeId: code};
  var depth = 0;
  var current = byId[codeId];

  while (current != null && !Code.isRootParent(current.pCodeId)) {
    depth++;
    current = byId[current.pCodeId.trim()];
  }

  return depth;
}
