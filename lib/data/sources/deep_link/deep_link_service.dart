import 'package:socialapp/utils/import.dart';

abstract class DeepLinkService {
  Future<void> generateVerifyLink(String otpCode);
}

class DeepLinkServiceImpl extends DeepLinkService {
  final AppLinks _appLinks = AppLinks();

  @override
  Future<void> generateVerifyLink(String otpCode) async {
    if (kDebugMode) {
      print("Clicked");
    }
    if (!kIsWeb) {
    } else {
      try {
        final Uri dynamicLink = Uri(
          scheme: 'https',
          host: 'zineround.site',
          path: '/verify', // Specify the path for OTP verification
          queryParameters: {
            'otp': otpCode, // OTP code query parameter
          },
        );

        if (kDebugMode) {
          print("Generated OTP link: $dynamicLink");
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error generating dynamic link : $e");
        }
      }
    }
  }

  void handleIncomingLinks() {
    // Listen for incoming dynamic links
    _appLinks.uriLinkStream.listen(
      (deepLink) {
        if (deepLink.path == '/verify') {
          final otpCode = deepLink.queryParameters['otp'];
          if (otpCode != null) {
            if (kDebugMode) {
              print("Navigating to verification page with OTP: $otpCode");
            }
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
