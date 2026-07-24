// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friends_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$friendsRepositoryHash() => r'ea71f8292d633399484edbf362eb3abd4b60987d';

/// See also [friendsRepository].
@ProviderFor(friendsRepository)
final friendsRepositoryProvider = Provider<FriendsRepository>.internal(
  friendsRepository,
  name: r'friendsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$friendsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FriendsRepositoryRef = ProviderRef<FriendsRepository>;
String _$friendsHash() => r'4bd4b246bed79e5babce77c4e0aad6f1d1d44121';

/// See also [friends].
@ProviderFor(friends)
final friendsProvider = AutoDisposeStreamProvider<List<FriendProfile>>.internal(
  friends,
  name: r'friendsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$friendsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FriendsRef = AutoDisposeStreamProviderRef<List<FriendProfile>>;
String _$incomingFriendRequestsHash() =>
    r'a7b4721112aba18c439f21093b7dce2cdc69af93';

/// See also [incomingFriendRequests].
@ProviderFor(incomingFriendRequests)
final incomingFriendRequestsProvider =
    AutoDisposeStreamProvider<List<FriendRequest>>.internal(
      incomingFriendRequests,
      name: r'incomingFriendRequestsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$incomingFriendRequestsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IncomingFriendRequestsRef =
    AutoDisposeStreamProviderRef<List<FriendRequest>>;
String _$outgoingFriendRequestsHash() =>
    r'ec5237b9074456c8b26992a1249c02e4a10d8477';

/// See also [outgoingFriendRequests].
@ProviderFor(outgoingFriendRequests)
final outgoingFriendRequestsProvider =
    AutoDisposeStreamProvider<List<FriendRequest>>.internal(
      outgoingFriendRequests,
      name: r'outgoingFriendRequestsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$outgoingFriendRequestsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OutgoingFriendRequestsRef =
    AutoDisposeStreamProviderRef<List<FriendRequest>>;
String _$friendProfileHash() => r'4a1a48358e14aaa7262c91c705e25b52bb2ca853';

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

/// See also [friendProfile].
@ProviderFor(friendProfile)
const friendProfileProvider = FriendProfileFamily();

/// See also [friendProfile].
class FriendProfileFamily extends Family<AsyncValue<FriendProfile?>> {
  /// See also [friendProfile].
  const FriendProfileFamily();

  /// See also [friendProfile].
  FriendProfileProvider call(String uid) {
    return FriendProfileProvider(uid);
  }

  @override
  FriendProfileProvider getProviderOverride(
    covariant FriendProfileProvider provider,
  ) {
    return call(provider.uid);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'friendProfileProvider';
}

/// See also [friendProfile].
class FriendProfileProvider extends AutoDisposeFutureProvider<FriendProfile?> {
  /// See also [friendProfile].
  FriendProfileProvider(String uid)
    : this._internal(
        (ref) => friendProfile(ref as FriendProfileRef, uid),
        from: friendProfileProvider,
        name: r'friendProfileProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$friendProfileHash,
        dependencies: FriendProfileFamily._dependencies,
        allTransitiveDependencies:
            FriendProfileFamily._allTransitiveDependencies,
        uid: uid,
      );

  FriendProfileProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.uid,
  }) : super.internal();

  final String uid;

  @override
  Override overrideWith(
    FutureOr<FriendProfile?> Function(FriendProfileRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FriendProfileProvider._internal(
        (ref) => create(ref as FriendProfileRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        uid: uid,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<FriendProfile?> createElement() {
    return _FriendProfileProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FriendProfileProvider && other.uid == uid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, uid.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FriendProfileRef on AutoDisposeFutureProviderRef<FriendProfile?> {
  /// The parameter `uid` of this provider.
  String get uid;
}

class _FriendProfileProviderElement
    extends AutoDisposeFutureProviderElement<FriendProfile?>
    with FriendProfileRef {
  _FriendProfileProviderElement(super.provider);

  @override
  String get uid => (origin as FriendProfileProvider).uid;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
