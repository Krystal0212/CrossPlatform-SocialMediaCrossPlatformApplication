import 'package:socialapp/utils/import.dart';
import 'widgets/splash_background.dart';
import 'widgets/splash_image_group.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    initialization();
  }

  void initialization() async {
    FlutterNativeSplash.remove();
    await Future.delayed(const Duration(seconds: 2));

    try {
      if (!mounted) return;
      bool isWeb = PlatformConfig.of(context)?.isWeb ?? false;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      final bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

      if (isFirstLaunch && !isWeb) {
        await prefs.setBool('isFirstLaunch', false);

        if (!mounted) return;
        context.go('/boarding');
      } else {
        if (!mounted) return;
        context.go('/sign-in');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: SplashBackground(
        center: Center(
          child: SplashImageGroup(),
        ),
      ),
    );
  }
}
