import 'package:socialapp/utils/import.dart';

abstract class DeepLinkService {}

class DeepLinkServiceImpl extends DeepLinkService {
  final AppLinks _appLinks = AppLinks();

  void handleIncomingLinks(GoRouter router) {
    // Listen for incoming dynamic links
    _appLinks.uriLinkStream.listen(
      (deepLink) {
        if (deepLink.hasEmptyPath) return;
        if (deepLink.hasFragment) {
          final String fragment = deepLink.fragment; // Get everything after #

          if (fragment.isNotEmpty && fragment.contains('?')) {
            final Map<String, String> hashParameters =
                Uri.splitQueryString(fragment.split('?').last);

            if (hashParameters.isNotEmpty && deepLink.path == '/verify') {
              router.go('/verify', extra: hashParameters);
            } else if (hashParameters.isNotEmpty &&
                deepLink.path == '/reset-password') {
              router.go('/reset-password ', extra: hashParameters);
            }
          }
        } else {
          final Map<String, String> hashParameters = deepLink.queryParameters;
          if (hashParameters.isNotEmpty && deepLink.path == '/verify') {
            router.go('/verify', extra: hashParameters);
          } else if (hashParameters.isNotEmpty && deepLink.path == '/reset-password') {
            router.go('/reset-password ', extra: hashParameters);
          }
        }
      },
      onError: (Object err) {
        if (kDebugMode) {
          print("Error handling incoming link: $err");
        }
      },
    );
  }
}
