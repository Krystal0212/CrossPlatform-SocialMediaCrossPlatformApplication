import 'package:socialapp/utils/import.dart';

class HomeProperties {
  final UserModel? user;
  final ValueNotifier<UserModel?> currentUserNotifier;
  final double listBodyWidth;

  HomeProperties(  {required this.listBodyWidth,
    required this.currentUserNotifier, required this.user,
  });
}

class HomePropertiesProvider extends InheritedWidget {
  final HomeProperties homeProperties;

  const HomePropertiesProvider({
    super.key,
    required this.homeProperties,
    required super.child,
  });

  static HomeProperties? of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<HomePropertiesProvider>();
    return provider?.homeProperties;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    // Return true if the data has changed and child widgets need to be notified
    return oldWidget is HomePropertiesProvider &&
        (oldWidget.homeProperties != homeProperties);
  }
}


class UserNotifierProvider extends InheritedNotifier<ValueNotifier<UserModel?>> {
  const UserNotifierProvider({
  super.key,
  required ValueNotifier<UserModel?> super.notifier,
  required super.child,
  });

  static ValueNotifier<UserModel?>? of(BuildContext context) {
  return context
      .dependOnInheritedWidgetOfExactType<UserNotifierProvider>()
      ?.notifier;
  }
}