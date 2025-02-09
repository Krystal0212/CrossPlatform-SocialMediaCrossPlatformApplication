import 'package:socialapp/utils/import.dart';

class HomeProperties {
  final UserModel? currentUser;
  final ValueNotifier<UserModel?> currentUserNotifier;
  final double listBodyWidth;
  final TextEditingController searchController;

  HomeProperties(  {required this.listBodyWidth,
    required this.currentUserNotifier, required this.currentUser, required this.searchController,
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