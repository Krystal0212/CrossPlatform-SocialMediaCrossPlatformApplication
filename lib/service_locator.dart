import 'package:socialapp/utils/import.dart';

final serviceLocator = GetIt.instance;

Future<void> initializeDependencies() async {

  serviceLocator.registerSingleton<AuthFirebaseService>(AuthFirebaseServiceImpl());
  serviceLocator.registerSingleton<AuthRepository>(AuthRepositoryImpl());

  serviceLocator.registerSingleton<UserService>(UserServiceImpl());
  serviceLocator.registerSingleton<UserRepository>(UserRepositoryImpl());

  serviceLocator.registerSingleton<FirestoreService>(FirestoreServiceImpl());
  serviceLocator.registerSingleton<TopicRepository>(TopicRepositoryImpl());

  serviceLocator.registerSingleton<DeepLinkService>(DeepLinkServiceImpl());

  serviceLocator.registerSingleton<CollectionService>(CollectionServiceImpl());
  serviceLocator.registerSingleton<CollectionRepository>(CollectionRepositoryImpl());

  serviceLocator.registerSingleton<PostService>(PostServiceImpl());
  serviceLocator.registerSingleton<PostRepository>(PostRepositoryImpl());

  serviceLocator.registerSingleton<CommentService>(CommentServiceImpl());
  serviceLocator.registerSingleton<CommentRepository>(CommentRepositoryImpl());
}
