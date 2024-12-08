import 'package:flutter/material.dart';

class PlatformConfig extends InheritedWidget {
  final bool isWeb;

  const PlatformConfig({super.key,
    required this.isWeb,
    required super.child,
  });

  static PlatformConfig? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PlatformConfig>();
  }

  @override
  bool updateShouldNotify(covariant PlatformConfig oldWidget) {
    return isWeb != oldWidget.isWeb;
  }
}
