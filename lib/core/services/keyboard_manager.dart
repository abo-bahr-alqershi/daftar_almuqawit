// keyboard_manager.dart
import 'package:flutter/material.dart';
import 'dart:async';

/// إدارة لوحة المفاتيح
class KeyboardManager {
  static final KeyboardManager _instance = KeyboardManager._internal();
  factory KeyboardManager() => _instance;
  KeyboardManager._internal();

  final StreamController<bool> _keyboardController =
      StreamController<bool>.broadcast();
  Stream<bool> get keyboardStream => _keyboardController.stream;

  bool _isKeyboardVisible = false;
  bool get isKeyboardVisible => _isKeyboardVisible;

  Timer? _debounceTimer;

  /// مراقبة حالة لوحة المفاتيح
  void updateKeyboardVisibility(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final newVisibility = keyboardHeight > 0;

    if (_isKeyboardVisible != newVisibility) {
      _isKeyboardVisible = newVisibility;
      _keyboardController.add(newVisibility);
    }
  }

  /// انتظار استقرار لوحة المفاتيح
  Future<void> waitForKeyboardAnimation({
    Duration duration = const Duration(milliseconds: 400),
  }) async {
    _debounceTimer?.cancel();

    final completer = Completer<void>();
    _debounceTimer = Timer(duration, () {
      completer.complete();
    });

    return completer.future;
  }

  /// إخفاء لوحة المفاتيح وانتظار اكتمال الإخفاء
  Future<void> hideKeyboardAndWait(BuildContext context) async {
    FocusScope.of(context).unfocus();

    // انتظار اكتمال animation لوحة المفاتيح
    await waitForKeyboardAnimation(duration: const Duration(milliseconds: 300));
  }

  /// طلب التركيز مع انتظار ظهور لوحة المفاتيح
  Future<void> requestFocusAndWait(
    BuildContext context,
    FocusNode focusNode,
  ) async {
    if (!context.mounted) return;

    // طلب التركيز
    FocusScope.of(context).requestFocus(focusNode);

    // انتظار ظهور لوحة المفاتيح واستقرار الواجهة
    await waitForKeyboardAnimation(duration: const Duration(milliseconds: 400));
  }

  void dispose() {
    _debounceTimer?.cancel();
    _keyboardController.close();
  }
}
