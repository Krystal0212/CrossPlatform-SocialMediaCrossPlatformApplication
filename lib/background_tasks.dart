import 'package:socialapp/utils/import.dart';

import 'presentation/screens/module_2/home/cubit/home_cubit.dart';

@pragma('vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await _initializeGetIt();

      // Fetch online data and cache it
      final bool isOffline = inputData?['isOffline'] ?? false;
      await serviceLocator<PostRepository>().getPostsData(isOffline: isOffline, skipLocalFetch: true);

      HomeCubit().setBackgroundFetchComplete(true);

      return Future.value(true);
    } catch (e) {
      // if (kDebugMode) {
      //   print("Error in background task: $e");
      // }
      return Future.value(false);
    }
  });
}

Future<void> _initializeGetIt() async {
  // Register your services and repositories in GetIt
  final getIt = GetIt.instance;

  // Register dependencies
  getIt.registerLazySingleton<PostRepository>(() => PostRepositoryImpl());
  getIt.registerLazySingleton<HomeCubit>(() => HomeCubit());
  // Add other dependencies as needed
}