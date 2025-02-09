import 'package:socialapp/utils/import.dart';

class UserDataInheritedWidget extends InheritedWidget {
  final UserModel currentUser;

  const UserDataInheritedWidget({
    super.key,
    required this.currentUser,
    required super.child,
  });

  // A static method to easily access the inherited data
  static UserDataInheritedWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<UserDataInheritedWidget>();
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true; // Return true if the data needs to be updated
  }
}
