// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lists_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$listsRepositoryHash() => r'54d6a0e7c09ce4ec7092fc6cb83feeebf7ab6b47';

/// See also [listsRepository].
@ProviderFor(listsRepository)
final listsRepositoryProvider = Provider<ListsRepository>.internal(
  listsRepository,
  name: r'listsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$listsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ListsRepositoryRef = ProviderRef<ListsRepository>;
String _$sharedListRepositoryHash() =>
    r'3fdf29fbf91fcc428b29a25c7c0069fecb39b6b1';

/// See also [sharedListRepository].
@ProviderFor(sharedListRepository)
final sharedListRepositoryProvider = Provider<SharedListRepository>.internal(
  sharedListRepository,
  name: r'sharedListRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sharedListRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SharedListRepositoryRef = ProviderRef<SharedListRepository>;
String _$allListsHash() => r'dd3bdb35e8c88761171c580de34f63ab42b45c82';

/// See also [allLists].
@ProviderFor(allLists)
final allListsProvider = AutoDisposeStreamProvider<List<TaskList>>.internal(
  allLists,
  name: r'allListsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allListsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllListsRef = AutoDisposeStreamProviderRef<List<TaskList>>;
String _$listByIdHash() => r'c3b247b9bad6a9be21408ecd5dd701abae422d2a';

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

/// See also [listById].
@ProviderFor(listById)
const listByIdProvider = ListByIdFamily();

/// See also [listById].
class ListByIdFamily extends Family<AsyncValue<TaskList?>> {
  /// See also [listById].
  const ListByIdFamily();

  /// See also [listById].
  ListByIdProvider call(String listId) {
    return ListByIdProvider(listId);
  }

  @override
  ListByIdProvider getProviderOverride(covariant ListByIdProvider provider) {
    return call(provider.listId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'listByIdProvider';
}

/// See also [listById].
class ListByIdProvider extends AutoDisposeStreamProvider<TaskList?> {
  /// See also [listById].
  ListByIdProvider(String listId)
    : this._internal(
        (ref) => listById(ref as ListByIdRef, listId),
        from: listByIdProvider,
        name: r'listByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$listByIdHash,
        dependencies: ListByIdFamily._dependencies,
        allTransitiveDependencies: ListByIdFamily._allTransitiveDependencies,
        listId: listId,
      );

  ListByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.listId,
  }) : super.internal();

  final String listId;

  @override
  Override overrideWith(
    Stream<TaskList?> Function(ListByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ListByIdProvider._internal(
        (ref) => create(ref as ListByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        listId: listId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<TaskList?> createElement() {
    return _ListByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ListByIdProvider && other.listId == listId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, listId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ListByIdRef on AutoDisposeStreamProviderRef<TaskList?> {
  /// The parameter `listId` of this provider.
  String get listId;
}

class _ListByIdProviderElement
    extends AutoDisposeStreamProviderElement<TaskList?>
    with ListByIdRef {
  _ListByIdProviderElement(super.provider);

  @override
  String get listId => (origin as ListByIdProvider).listId;
}

String _$sharedTasksForListHash() =>
    r'50b8e6eebccf38cbde881d70ad17665d2f799902';

/// See also [sharedTasksForList].
@ProviderFor(sharedTasksForList)
const sharedTasksForListProvider = SharedTasksForListFamily();

/// See also [sharedTasksForList].
class SharedTasksForListFamily extends Family<AsyncValue<List<SharedTask>>> {
  /// See also [sharedTasksForList].
  const SharedTasksForListFamily();

  /// See also [sharedTasksForList].
  SharedTasksForListProvider call(String listId) {
    return SharedTasksForListProvider(listId);
  }

  @override
  SharedTasksForListProvider getProviderOverride(
    covariant SharedTasksForListProvider provider,
  ) {
    return call(provider.listId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'sharedTasksForListProvider';
}

/// See also [sharedTasksForList].
class SharedTasksForListProvider
    extends AutoDisposeStreamProvider<List<SharedTask>> {
  /// See also [sharedTasksForList].
  SharedTasksForListProvider(String listId)
    : this._internal(
        (ref) => sharedTasksForList(ref as SharedTasksForListRef, listId),
        from: sharedTasksForListProvider,
        name: r'sharedTasksForListProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$sharedTasksForListHash,
        dependencies: SharedTasksForListFamily._dependencies,
        allTransitiveDependencies:
            SharedTasksForListFamily._allTransitiveDependencies,
        listId: listId,
      );

  SharedTasksForListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.listId,
  }) : super.internal();

  final String listId;

  @override
  Override overrideWith(
    Stream<List<SharedTask>> Function(SharedTasksForListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SharedTasksForListProvider._internal(
        (ref) => create(ref as SharedTasksForListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        listId: listId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<SharedTask>> createElement() {
    return _SharedTasksForListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SharedTasksForListProvider && other.listId == listId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, listId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SharedTasksForListRef on AutoDisposeStreamProviderRef<List<SharedTask>> {
  /// The parameter `listId` of this provider.
  String get listId;
}

class _SharedTasksForListProviderElement
    extends AutoDisposeStreamProviderElement<List<SharedTask>>
    with SharedTasksForListRef {
  _SharedTasksForListProviderElement(super.provider);

  @override
  String get listId => (origin as SharedTasksForListProvider).listId;
}

String _$listMembersHash() => r'73a93b7bdf70e40e81968e0a4d576f6f0de2e9ee';

/// See also [listMembers].
@ProviderFor(listMembers)
const listMembersProvider = ListMembersFamily();

/// See also [listMembers].
class ListMembersFamily extends Family<AsyncValue<List<ListMember>>> {
  /// See also [listMembers].
  const ListMembersFamily();

  /// See also [listMembers].
  ListMembersProvider call(String listId) {
    return ListMembersProvider(listId);
  }

  @override
  ListMembersProvider getProviderOverride(
    covariant ListMembersProvider provider,
  ) {
    return call(provider.listId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'listMembersProvider';
}

/// See also [listMembers].
class ListMembersProvider extends AutoDisposeStreamProvider<List<ListMember>> {
  /// See also [listMembers].
  ListMembersProvider(String listId)
    : this._internal(
        (ref) => listMembers(ref as ListMembersRef, listId),
        from: listMembersProvider,
        name: r'listMembersProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$listMembersHash,
        dependencies: ListMembersFamily._dependencies,
        allTransitiveDependencies: ListMembersFamily._allTransitiveDependencies,
        listId: listId,
      );

  ListMembersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.listId,
  }) : super.internal();

  final String listId;

  @override
  Override overrideWith(
    Stream<List<ListMember>> Function(ListMembersRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ListMembersProvider._internal(
        (ref) => create(ref as ListMembersRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        listId: listId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<ListMember>> createElement() {
    return _ListMembersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ListMembersProvider && other.listId == listId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, listId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ListMembersRef on AutoDisposeStreamProviderRef<List<ListMember>> {
  /// The parameter `listId` of this provider.
  String get listId;
}

class _ListMembersProviderElement
    extends AutoDisposeStreamProviderElement<List<ListMember>>
    with ListMembersRef {
  _ListMembersProviderElement(super.provider);

  @override
  String get listId => (origin as ListMembersProvider).listId;
}

String _$listsSharedWithMeHash() => r'a47dd1ffa3da0805589247a2346dc68e8daa182f';

/// See also [listsSharedWithMe].
@ProviderFor(listsSharedWithMe)
final listsSharedWithMeProvider =
    AutoDisposeStreamProvider<List<SharedListSummary>>.internal(
      listsSharedWithMe,
      name: r'listsSharedWithMeProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$listsSharedWithMeHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ListsSharedWithMeRef =
    AutoDisposeStreamProviderRef<List<SharedListSummary>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
