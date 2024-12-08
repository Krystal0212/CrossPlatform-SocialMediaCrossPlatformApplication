import 'package:socialapp/utils/import.dart';

abstract class DynamicLinkService {
  Future<void> generateVerifyLink(String otpCode);
}

class DynamicLinkServiceImpl extends DynamicLinkService {
  final FirebaseDynamicLinks _dynamicLink = FirebaseDynamicLinks.instance;

  @override
  Future<void> generateVerifyLink(String otpCode) async {
    if (kIsWeb) {
      // handleInitialLink();
    } else {
      try {
        if (kDebugMode) {
          print("Generated short link:");
        }
        // Create the link with OTP as a query parameter
        final Uri deepLink =
            Uri.parse("https://www.example.com/verify?otp=$otpCode");

        final DynamicLinkParameters parameters = DynamicLinkParameters(
          link: deepLink,
          uriPrefix: "https://example.page.link",
          androidParameters:
              const AndroidParameters(packageName: "com.example.app.android"),
          iosParameters: const IOSParameters(bundleId: "com.example.app.ios"),
        );

        // Generate a short link
        final ShortDynamicLink shortDynamicLink =
            await _dynamicLink.buildShortLink(parameters);
        final Uri shortLink = shortDynamicLink.shortUrl;

        // Log or return the generated short link
        if (kDebugMode) {
          print("Generated short link: $shortLink");
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error generating dynamic link : $e");
        }
      }
    }
  }

  Future<void> handleInitialLink() async {
      final PendingDynamicLinkData? data = await _dynamicLink.getInitialLink();
      final Uri? deepLink = data?.link;

      if (deepLink != null) {
        // Handle the deep link here
        if (kDebugMode) {
          print("Received deep link: $deepLink");
        }
      }
  }
}
