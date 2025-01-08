import 'package:socialapp/presentation/screens/module_1/preferred-topics/cubit/preferred_topic_cubit.dart';
import 'package:socialapp/presentation/screens/module_1/reset_password/cubit/reset_password_cubit.dart';
import 'package:socialapp/presentation/widgets/general/custom_placeholder.dart';
import 'package:socialapp/utils/import.dart';
import '../presentation/screens/module_1/reset_password/reset_password_screen.dart';

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
        path: '/forgot-password',
        pageBuilder: (context, state) =>
            _buildPageRoute(const ForgotPasswordScreen()),
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
          pageBuilder: (context, state) {
            String params = "";
            bool? isFromSignIn;

            if (state.extra != null && state.extra is Map<String, dynamic>) {
              final extraData = state.extra as Map<String, dynamic>;
              params = extraData["code"]?.toString() ?? "";
              isFromSignIn = extraData["isFromSignIn"] as bool?;
            }

            return _buildPageRoute(
              BlocProvider(
                  create: (context) => VerificationCubit(),
                  child: VerificationScreen(
                    hashParameters: params,
                    isFromSignIn: isFromSignIn,
                  )),
            );
          }),
      GoRoute(
          path: '/preferred-topic',
          // pageBuilder: (context, state) => _buildPageRoute(const PreferredTopicsScreen())),
          pageBuilder: (context, state) => _buildPageRoute(BlocProvider(
              create: (_) => PreferredTopicCubit(),
              child: const PreferredTopicsScreen()))),
      GoRoute(
          path: '/reset-password',
          pageBuilder: (context, state) {
            String params = "";

            if (state.extra != null && state.extra is Map<String, dynamic>) {
              final extraData = state.extra as Map<String, dynamic>;
              params = extraData["code"]?.toString() ?? "";
            }

            return _buildPageRoute(BlocProvider(
                create: (context) => ResetPasswordCubit(),
                child: ResetPasswordScreen(
                  hashParameters: params,
                )));
          }),
      GoRoute(
          path: '/home',
          pageBuilder: (context, state) => _buildPageRoute(const HomeScreen())),
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
