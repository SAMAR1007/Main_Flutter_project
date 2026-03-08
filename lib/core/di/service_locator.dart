import 'package:get_it/get_it.dart';
import '../../features/auth/data/datasource/remote/auth_remote_datasource.dart';
import '../../features/auth/data/datasource/remote/auth_remote_datasource_impl.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../network/api_client.dart';
import '../network/local_storage_service.dart';
import '../providers/product_provider.dart';
import '../providers/order_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/dashboard_provider.dart';
import '../services/socket_service.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Network services
  final apiClient = ApiClient();
  getIt.registerSingleton<ApiClient>(apiClient);

  final storageService = LocalStorageService();
  await storageService.init();
  getIt.registerSingleton<LocalStorageService>(storageService);

  // Restore token from storage if available
  final storedToken = await storageService.getToken();
  if (storedToken != null) {
    apiClient.setToken(storedToken);
  }

  // Data sources
  getIt.registerSingleton<AuthRemoteDataSource>(
    AuthRemoteDataSourceImpl(
      apiClient: getIt<ApiClient>(),
    ),
  );

  // Repositories
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
    ),
  );

  // Use cases
  getIt.registerSingleton<RegisterUseCase>(
    RegisterUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<LoginUseCase>(
    LoginUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<GetProfileUseCase>(
    GetProfileUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<UpdateProfileUseCase>(
    UpdateProfileUseCase(getIt<AuthRepository>()),
  );

  // Providers
  getIt.registerSingleton<AuthProvider>(
    AuthProvider(
      registerUseCase: getIt<RegisterUseCase>(),
      loginUseCase: getIt<LoginUseCase>(),
      getProfileUseCase: getIt<GetProfileUseCase>(),
      updateProfileUseCase: getIt<UpdateProfileUseCase>(),
      apiClient: getIt<ApiClient>(),
      storageService: getIt<LocalStorageService>(),
    ),
  );

  getIt.registerSingleton<ProductProvider>(
    ProductProvider(
      apiClient: getIt<ApiClient>(),
      storageService: getIt<LocalStorageService>(),
    ),
  );

  getIt.registerSingleton<OrderProvider>(
    OrderProvider(apiClient: getIt<ApiClient>()),
  );

  // Cart (offline-capable)
  getIt.registerSingleton<CartProvider>(
    CartProvider(storageService: getIt<LocalStorageService>()),
  );

  // Dashboard
  getIt.registerSingleton<DashboardProvider>(
    DashboardProvider(apiClient: getIt<ApiClient>()),
  );

  // Socket & Chat
  getIt.registerSingleton<SocketService>(SocketService());

  getIt.registerSingleton<ChatProvider>(
    ChatProvider(
      apiClient: getIt<ApiClient>(),
      socketService: getIt<SocketService>(),
    ),
  );
}
