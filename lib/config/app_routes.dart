import 'package:socialapp/presentation/screens/home/home_screen.dart';
import 'package:socialapp/utils/import.dart';

import '../presentation/screens/verification/cubit/verification_cubit.dart';

class AppRoutes {
  static final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => _buildPageRoute(const SplashScreen()),
      ),
      GoRoute(
        path: '/boarding',
        pageBuilder: (context, state) =>
            _buildPageRoute(const BoardingScreen()),
      ),
      GoRoute(
        path: '/sign-in',
        pageBuilder: (context, state) => _buildPageRoute(const SignInScreen()),
      ),
      GoRoute(
        path: '/sign-up',
        pageBuilder: (context, state) => _buildPageRoute(const SignUpScreen()),
      ),
      GoRoute(
          path: '/verify',
          builder: (context, state) {
            String params = (state.extra != null) ? (state.extra as Map<String, String>)["code"].toString() : "";
            return BlocProvider(
                create: (context) => VerificationCubit(),
                child: VerificationScreen(hashParameters: params));
          }),
      GoRoute(path: '/home', pageBuilder: (context, state) => _buildPageRoute(const HomeScreen())),
    ],
    errorBuilder: (context, state) => const AppPlaceHolder(),
  );

  static GoRouter getRoutes() => router;

  // Method to handle route creation with no animation
  static CustomTransitionPage _buildPageRoute(Widget page) {
    return CustomTransitionPage(
      // key: UniqueKey(),
      child: page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Return the child directly without any animation
        return child;
      },
    );
  }

// static Map<String, WidgetBuilder> getRoutes() {
//   return {
//     '/': (context) => const SplashScreen(),
//     '/boarding': (context) => const BoardingScreen(),
//     '/sign-in': (context) => const SignInScreen(),
//     '/sign-up': (context) => const SignUpScreen(),
//     // Add more routes here as needed
//   };
// }

// static Route<dynamic> generateRoute(RouteSettings settings) {
//   switch (settings.name) {
//     case '/':
//       return _buildPageRoute(const SplashScreen());
//     case '/boarding':
//       return _buildPageRoute(const BoardingScreen());
//     case '/sign-in':
//       return _buildPageRoute(const SignInScreen());
//     case '/sign-up':
//       return _buildPageRoute(const SignUpScreen());
//     case '/verify':
//       return _buildPageRoute(const VerificationScreen());
//     // Add more cases for other routes
//     default:
//       return _buildPageRoute(
//           const AppPlaceHolder()); // Define a default 404 page
//   }
// }
}
