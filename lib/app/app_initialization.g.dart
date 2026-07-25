// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_initialization.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appInitializationHash() => r'9ef7fbc178b3bbf3f843965275003f87bdc5e83f';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Runs once per signed-in user: sets up local notifications, seeds a
/// default list, mirrors the user's profile to Firestore (so others can
/// find them by email to invite to a shared list), registers this device
/// for push notifications, applies any home-widget taps made while the
/// app wasn't open, and starts keeping the widget's data fresh.
///
/// Copied from [appInitialization].
@ProviderFor(appInitialization)
const appInitializationProvider = AppInitializationFamily();

/// Runs once per signed-in user: sets up local notifications, seeds a
/// default list, mirrors the user's profile to Firestore (so others can
/// find them by email to invite to a shared list), registers this device
/// for push notifications, applies any home-widget taps made while the
/// app wasn't open, and starts keeping the widget's data fresh.
///
/// Copied from [appInitialization].
class AppInitializationFamily extends Family<AsyncValue<void>> {
  /// Runs once per signed-in user: sets up local notifications, seeds a
  /// default list, mirrors the user's profile to Firestore (so others can
  /// find them by email to invite to a shared list), registers this device
  /// for push notifications, applies any home-widget taps made while the
  /// app wasn't open, and starts keeping the widget's data fresh.
  ///
  /// Copied from [appInitialization].
  const AppInitializationFamily();

  /// Runs once per signed-in user: sets up local notifications, seeds a
  /// default list, mirrors the user's profile to Firestore (so others can
  /// find them by email to invite to a shared list), registers this device
  /// for push notifications, applies any home-widget taps made while the
  /// app wasn't open, and starts keeping the widget's data fresh.
  ///
  /// Copied from [appInitialization].
  AppInitializationProvider call(String userId) {
    return AppInitializationProvider(userId);
  }

  @override
  AppInitializationProvider getProviderOverride(
    covariant AppInitializationProvider provider,
  ) {
    return call(provider.userId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'appInitializationProvider';
}

/// Runs once per signed-in user: sets up local notifications, seeds a
/// default list, mirrors the user's profile to Firestore (so others can
/// find them by email to invite to a shared list), registers this device
/// for push notifications, applies any home-widget taps made while the
/// app wasn't open, and starts keeping the widget's data fresh.
///
/// Copied from [appInitialization].
class AppInitializationProvider extends AutoDisposeFutureProvider<void> {
  /// Runs once per signed-in user: sets up local notifications, seeds a
  /// default list, mirrors the user's profile to Firestore (so others can
  /// find them by email to invite to a shared list), registers this device
  /// for push notifications, applies any home-widget taps made while the
  /// app wasn't open, and starts keeping the widget's data fresh.
  ///
  /// Copied from [appInitialization].
  AppInitializationProvider(String userId)
    : this._internal(
        (ref) => appInitialization(ref as AppInitializationRef, userId),
        from: appInitializationProvider,
        name: r'appInitializationProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$appInitializationHash,
        dependencies: AppInitializationFamily._dependencies,
        allTransitiveDependencies:
            AppInitializationFamily._allTransitiveDependencies,
        userId: userId,
      );

  AppInitializationProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    FutureOr<void> Function(AppInitializationRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AppInitializationProvider._internal(
        (ref) => create(ref as AppInitializationRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<void> createElement() {
    return _AppInitializationProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AppInitializationProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AppInitializationRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _AppInitializationProviderElement
    extends AutoDisposeFutureProviderElement<void>
    with AppInitializationRef {
  _AppInitializationProviderElement(super.provider);

  @override
  String get userId => (origin as AppInitializationProvider).userId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
