import 'package:socialapp/presentation/screens/verification/verification_screen.dart';
import 'package:socialapp/utils/import.dart';

class AppRoutes {
  // static Map<String, WidgetBuilder> getRoutes() {
  //   return {
  //     '/': (context) => const SplashScreen(),
  //     '/boarding': (context) => const BoardingScreen(),
  //     '/sign-in': (context) => const SignInScreen(),
  //     '/sign-up': (context) => const SignUpScreen(),
  //     // Add more routes here as needed
  //   };
  // }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _buildPageRoute(const SplashScreen());
      case '/boarding':
        return _buildPageRoute(const BoardingScreen());
      case '/sign-in':
        return _buildPageRoute(BlocProvider(
            create: (_) => SignInCubit(), child: const SignInScreen()));
      case '/sign-up':
        return _buildPageRoute(const SignUpScreen());
      case '/verify':
        return _buildPageRoute(const VerificationScreen());
      // Add more cases for other routes
      default:
        return _buildPageRoute(
            const AppPlaceHolder()); // Define a default 404 page
    }
  }

  // Method to handle route creation with no animation
  static PageRouteBuilder _buildPageRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    );
  }
}
