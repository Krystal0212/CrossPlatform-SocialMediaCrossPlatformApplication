import 'package:pulp_flash/pulp_flash.dart';
import 'package:socialapp/presentation/screens/module_2/home/cubit/home_cubit.dart';
import 'package:socialapp/utils/import.dart';
import 'background_tasks.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getApplicationDocumentsDirectory(),
  );

  await initializeDependencies();

  // if (!kIsWeb) {
  //   Workmanager().initialize(
  //     callbackDispatcher, // The top level function
  //     isInDebugMode: kDebugMode,
  //   );
  // }

  final dynamicLinkService = DeepLinkServiceImpl();
  dynamicLinkService.handleIncomingLinks(AppRoutes.router);

  runApp(
    const PlatformConfig(
      isWeb: kIsWeb,
      child: PulpFlashProvider(child: MyApp()),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // final dynamicLinkService = DeepLinkServiceImpl();
  @override
  void initState() {
    super.initState();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // dynamicLinkService.handleIncomingLinks(AppRoutes.getRoutes());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp.router(
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch, PointerDeviceKind.stylus, PointerDeviceKind.unknown},
        ),
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRoutes.getRoutes(),
      ),
    );
  }
}
