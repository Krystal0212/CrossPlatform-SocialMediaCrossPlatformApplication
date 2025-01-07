import 'package:socialapp/presentation/screens/module_1/preferred-topics/cubit/preferred_topic_cubit.dart';
import 'package:socialapp/presentation/screens/module_1/reset_password/cubit/reset_password_cubit.dart';
import 'package:socialapp/presentation/screens/module_2/home/cubit/home_cubit.dart';
import 'package:socialapp/presentation/screens/module_2/mobile_navigator/navigator_bar.dart';
import 'package:socialapp/presentation/screens/module_2/new_post/new_post_screen.dart';
import 'package:socialapp/utils/import.dart';

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
                child: VerificationScreen(
                  hashParameters: params,
                )));
          }),
      GoRoute(
          path: '/home',
          pageBuilder: (context, state) {
            final isWeb = PlatformConfig.of(context)?.isWeb ?? false;

            if(isWeb) {
              return _buildPageRoute(BlocProvider(
                create: (context) => HomeCubit(), child: const HomeScreen()));
            }else{
              return _buildPageRoute(const CustomNavigatorBar());
            }
          }),
      GoRoute(
          path: '/new-post',
          pageBuilder: (context, state) {
            final isWeb = PlatformConfig.of(context)?.isWeb ?? false;

            if(isWeb) {
              return _buildPageRoute(BlocProvider(
                  create: (context) => HomeCubit(), child: const HomeScreen()));
            }
            else {
              return _buildPageRoute(const NewPostScreen());
            }
          })
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
}
