import 'package:socialapp/utils/import.dart';

abstract class DeepLinkService {

}

class DeepLinkServiceImpl extends DeepLinkService {
  final AppLinks _appLinks = AppLinks();

  void handleIncomingLinks(GoRouter router) {
    // Listen for incoming dynamic links
    _appLinks.uriLinkStream.listen(
      (deepLink) {
        if (deepLink.hasEmptyPath) return;
        if (deepLink.hasFragment) {
          final String fragment = deepLink.fragment; // Get everything after `#`

          if (fragment.isNotEmpty && fragment.contains('?')) {
            final Map<String, String> hashParameters = Uri.splitQueryString(fragment.split('?').last);

            // if (kDebugMode) {
            //   print("Navigating to verification page with link: ${hashParameters.toString()}");
            // }

            if (hashParameters.isNotEmpty) {
              router.go('/verify', extra: hashParameters);
            }
          }
        } else {
          final Map<String, String> hashParameters = deepLink.queryParameters;
          if (deepLink.path == '/verify' && hashParameters.isNotEmpty ) {
            if (kDebugMode) {
              print("Navigating to verification page with OTP: ${hashParameters.toString()}");
            }
            router.go('/verify', extra: hashParameters);
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
