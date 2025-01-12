import 'package:socialapp/utils/import.dart';

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
