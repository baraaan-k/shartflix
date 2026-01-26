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
}
