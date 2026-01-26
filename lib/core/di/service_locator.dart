import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_token_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';

class ServiceLocator {
  ServiceLocator._();

  static final ServiceLocator instance = ServiceLocator._();

  final Map<Type, dynamic Function()> _factories = {};
  final Map<Type, dynamic> _instances = {};

  void registerLazySingleton<T>(T Function() factory) {
    _factories[T] = factory;
  }

  T get<T>() {
    final existing = _instances[T];
    if (existing != null) {
      return existing as T;
    }
    final factory = _factories[T];
    if (factory == null) {
      throw StateError('No factory registered for type $T');
    }
    final instance = factory();
    _instances[T] = instance;
    return instance as T;
  }

  void reset() {
    _factories.clear();
    _instances.clear();
  }
}

void setupDependencies() {
  final sl = ServiceLocator.instance;
  sl.reset();

  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => FakeAuthRemoteDataSource(),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl.get<FlutterSecureStorage>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remote: sl.get<AuthRemoteDataSource>(),
      local: sl.get<AuthLocalDataSource>(),
    ),
  );
  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(sl.get<AuthRepository>()),
  );
  sl.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(sl.get<AuthRepository>()),
  );
  sl.registerLazySingleton<GetTokenUseCase>(
    () => GetTokenUseCase(sl.get<AuthRepository>()),
  );
  sl.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(sl.get<AuthRepository>()),
  );
}
