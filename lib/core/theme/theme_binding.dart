import 'package:flutter/material.dart';

class ThemeBinding extends InheritedNotifier<ValueNotifier<ThemeMode>> {
  const ThemeBinding({
    super.key,
    required ValueNotifier<ThemeMode> notifier,
    required super.child,
  }) : super(notifier: notifier);

  static ThemeMode of(BuildContext context) {
    final widget =
        context.dependOnInheritedWidgetOfExactType<ThemeBinding>();
    return widget?.notifier?.value ?? ThemeMode.dark;
  }
}
