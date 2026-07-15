import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';

extension TkFeedback on BuildContext {
  void showTkMessage(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void showTkApiError(ApiException error) {
    showTkMessage(error.message);
  }
}