import 'package:flutter/material.dart';

Future<bool> showTkConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = '삭제',
  String cancelLabel = '취소',
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );

  return confirmed == true;
}
