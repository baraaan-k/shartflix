import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_token_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../network/api_client.dart';
import '../../features/home/data/datasources/movies_remote_data_source.dart';
import '../../features/home/data/repositories/movies_repository_impl.dart';
import '../../features/home/domain/repositories/movies_repository.dart';
import '../../features/home/domain/usecases/get_movies_page_usecase.dart';
import '../../features/favorites/data/datasources/favorites_local_data_source.dart';
import '../../features/favorites/data/repositories/favorites_repository_impl.dart';
import '../../features/favorites/domain/repositories/favorites_repository.dart';
import '../../features/favorites/domain/usecases/get_favorites_usecase.dart';
import '../../features/favorites/domain/usecases/toggle_favorite_usecase.dart';
import '../../features/favorites/presentation/bloc/favorites_cubit.dart';
import '../../features/profile/data/datasources/profile_local_data_source.dart';
import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/fetch_profile_usecase.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/profile/domain/usecases/set_avatar_usecase.dart';
import '../../features/profile/domain/usecases/upload_photo_usecase.dart';
import '../../features/profile/presentation/bloc/profile_cubit.dart';
import '../../features/offer/data/offer_flag_store.dart';
import '../localization/app_locale_controller.dart';
import '../localization/locale_prefs_store.dart';

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
    () => const FlutterSecureStorage(
      iOptions: AuthLocalDataSourceImpl.iosOptions,
      aOptions: AuthLocalDataSourceImpl.androidOptions,
    ),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl.get<FlutterSecureStorage>()),
  );
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(authLocalDataSource: sl.get<AuthLocalDataSource>()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl.get<ApiClient>()),
  );
  sl.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSource(),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remote: sl.get<AuthRemoteDataSource>(),
      local: sl.get<AuthLocalDataSource>(),
      profileLocalDataSource: sl.get<ProfileLocalDataSource>(),
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
    () => LogoutUseCase(
      sl.get<AuthRepository>(),
      sl.get<ProfileRepository>(),
    ),
  );
  sl.registerLazySingleton<MoviesRemoteDataSource>(
    () => FakeMoviesRemoteDataSource(),
  );
  sl.registerLazySingleton<MoviesRepository>(
    () => MoviesRepositoryImpl(sl.get<MoviesRemoteDataSource>()),
  );
  sl.registerLazySingleton<GetMoviesPageUseCase>(
    () => GetMoviesPageUseCase(sl.get<MoviesRepository>()),
  );
  sl.registerLazySingleton<FavoritesLocalDataSource>(
    () => FavoritesLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(sl.get<FavoritesLocalDataSource>()),
  );
  sl.registerLazySingleton<GetFavoritesUseCase>(
    () => GetFavoritesUseCase(sl.get<FavoritesRepository>()),
  );
  sl.registerLazySingleton<ToggleFavoriteUseCase>(
    () => ToggleFavoriteUseCase(sl.get<FavoritesRepository>()),
  );
  sl.registerLazySingleton<FavoritesCubit>(
    () => FavoritesCubit(
      getFavoritesUseCase: sl.get<GetFavoritesUseCase>(),
      toggleFavoriteUseCase: sl.get<ToggleFavoriteUseCase>(),
    ),
  );
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSource(sl.get<ApiClient>()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      profileLocalDataSource: sl.get<ProfileLocalDataSource>(),
      profileRemoteDataSource: sl.get<ProfileRemoteDataSource>(),
    ),
  );
  sl.registerLazySingleton<GetProfileUseCase>(
    () => GetProfileUseCase(sl.get<ProfileRepository>()),
  );
  sl.registerLazySingleton<FetchProfileUseCase>(
    () => FetchProfileUseCase(sl.get<ProfileRepository>()),
  );
  sl.registerLazySingleton<SetAvatarUseCase>(
    () => SetAvatarUseCase(sl.get<ProfileRepository>()),
  );
  sl.registerLazySingleton<UploadPhotoUseCase>(
    () => UploadPhotoUseCase(sl.get<ProfileRepository>()),
  );
  sl.registerLazySingleton<ProfileCubit>(
    () => ProfileCubit(
      getProfileUseCase: sl.get<GetProfileUseCase>(),
      setAvatarUseCase: sl.get<SetAvatarUseCase>(),
      fetchProfileUseCase: sl.get<FetchProfileUseCase>(),
      uploadPhotoUseCase: sl.get<UploadPhotoUseCase>(),
    ),
  );
  sl.registerLazySingleton<OfferFlagStore>(
    () => OfferFlagStore(),
  );
  sl.registerLazySingleton<LocalePrefsStore>(
    () => LocalePrefsStore(),
  );
  sl.registerLazySingleton<AppLocaleController>(
    () => AppLocaleController(sl.get<LocalePrefsStore>()),
  );
}
