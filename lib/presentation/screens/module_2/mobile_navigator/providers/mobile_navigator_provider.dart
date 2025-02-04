import 'package:socialapp/utils/import.dart';

class MobileNavigatorProperties {
  final VoidCallback navigateToCurrentUserProfile;
  final void Function(String) navigateToOtherUserProfile;

  MobileNavigatorProperties({required this.navigateToOtherUserProfile, required this.navigateToCurrentUserProfile,
  });
}

class MobileNavigatorPropertiesProvider extends InheritedWidget {
  final MobileNavigatorProperties mobileNavigatorProperties;

  const MobileNavigatorPropertiesProvider({
    super.key,
    required this.mobileNavigatorProperties,
    required super.child,
  });

  static MobileNavigatorProperties? of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<MobileNavigatorPropertiesProvider>();
    return provider?.mobileNavigatorProperties;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    // Return true if the data has changed and child widgets need to be notified
    return oldWidget is MobileNavigatorPropertiesProvider &&
        (oldWidget.mobileNavigatorProperties != mobileNavigatorProperties);
  }
}