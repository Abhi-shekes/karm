// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tasks_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tasksRepositoryHash() => r'c9e08a445c030eaa41dcd3ce3aae085ca1f259ec';

/// See also [tasksRepository].
@ProviderFor(tasksRepository)
final tasksRepositoryProvider = Provider<TasksRepository>.internal(
  tasksRepository,
  name: r'tasksRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tasksRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TasksRepositoryRef = ProviderRef<TasksRepository>;
String _$todayTasksHash() => r'26dae25d5caf084727d6f5970333e0425ce20bed';

/// See also [todayTasks].
@ProviderFor(todayTasks)
final todayTasksProvider = AutoDisposeStreamProvider<List<Task>>.internal(
  todayTasks,
  name: r'todayTasksProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todayTasksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayTasksRef = AutoDisposeStreamProviderRef<List<Task>>;
String _$upcomingTasksHash() => r'ffc4b1f22318ee6af7670f60f48b26a19dba89f1';

/// See also [upcomingTasks].
@ProviderFor(upcomingTasks)
final upcomingTasksProvider = AutoDisposeStreamProvider<List<Task>>.internal(
  upcomingTasks,
  name: r'upcomingTasksProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$upcomingTasksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UpcomingTasksRef = AutoDisposeStreamProviderRef<List<Task>>;
String _$tasksForListHash() => r'8ffd0d9b7de7c655a245cf0246467104b429ffd0';

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

/// See also [tasksForList].
@ProviderFor(tasksForList)
const tasksForListProvider = TasksForListFamily();

/// See also [tasksForList].
class TasksForListFamily extends Family<AsyncValue<List<Task>>> {
  /// See also [tasksForList].
  const TasksForListFamily();

  /// See also [tasksForList].
  TasksForListProvider call(String listId) {
    return TasksForListProvider(listId);
  }

  @override
  TasksForListProvider getProviderOverride(
    covariant TasksForListProvider provider,
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
  String? get name => r'tasksForListProvider';
}

/// See also [tasksForList].
class TasksForListProvider extends AutoDisposeStreamProvider<List<Task>> {
  /// See also [tasksForList].
  TasksForListProvider(String listId)
    : this._internal(
        (ref) => tasksForList(ref as TasksForListRef, listId),
        from: tasksForListProvider,
        name: r'tasksForListProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$tasksForListHash,
        dependencies: TasksForListFamily._dependencies,
        allTransitiveDependencies:
            TasksForListFamily._allTransitiveDependencies,
        listId: listId,
      );

  TasksForListProvider._internal(
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
    Stream<List<Task>> Function(TasksForListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TasksForListProvider._internal(
        (ref) => create(ref as TasksForListRef),
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
  AutoDisposeStreamProviderElement<List<Task>> createElement() {
    return _TasksForListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TasksForListProvider && other.listId == listId;
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
mixin TasksForListRef on AutoDisposeStreamProviderRef<List<Task>> {
  /// The parameter `listId` of this provider.
  String get listId;
}

class _TasksForListProviderElement
    extends AutoDisposeStreamProviderElement<List<Task>>
    with TasksForListRef {
  _TasksForListProviderElement(super.provider);

  @override
  String get listId => (origin as TasksForListProvider).listId;
}

String _$allTasksWithDueDatesHash() =>
    r'f046c1bb2aaa268108d09f3b67389eccf2cf785d';

/// See also [allTasksWithDueDates].
@ProviderFor(allTasksWithDueDates)
final allTasksWithDueDatesProvider =
    AutoDisposeStreamProvider<List<Task>>.internal(
      allTasksWithDueDates,
      name: r'allTasksWithDueDatesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$allTasksWithDueDatesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllTasksWithDueDatesRef = AutoDisposeStreamProviderRef<List<Task>>;
String _$subtasksForTaskHash() => r'dfceceef2b024e28211d324f81422803500736fc';

/// See also [subtasksForTask].
@ProviderFor(subtasksForTask)
const subtasksForTaskProvider = SubtasksForTaskFamily();

/// See also [subtasksForTask].
class SubtasksForTaskFamily extends Family<AsyncValue<List<Subtask>>> {
  /// See also [subtasksForTask].
  const SubtasksForTaskFamily();

  /// See also [subtasksForTask].
  SubtasksForTaskProvider call(String taskId) {
    return SubtasksForTaskProvider(taskId);
  }

  @override
  SubtasksForTaskProvider getProviderOverride(
    covariant SubtasksForTaskProvider provider,
  ) {
    return call(provider.taskId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'subtasksForTaskProvider';
}

/// See also [subtasksForTask].
class SubtasksForTaskProvider extends AutoDisposeStreamProvider<List<Subtask>> {
  /// See also [subtasksForTask].
  SubtasksForTaskProvider(String taskId)
    : this._internal(
        (ref) => subtasksForTask(ref as SubtasksForTaskRef, taskId),
        from: subtasksForTaskProvider,
        name: r'subtasksForTaskProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$subtasksForTaskHash,
        dependencies: SubtasksForTaskFamily._dependencies,
        allTransitiveDependencies:
            SubtasksForTaskFamily._allTransitiveDependencies,
        taskId: taskId,
      );

  SubtasksForTaskProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.taskId,
  }) : super.internal();

  final String taskId;

  @override
  Override overrideWith(
    Stream<List<Subtask>> Function(SubtasksForTaskRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SubtasksForTaskProvider._internal(
        (ref) => create(ref as SubtasksForTaskRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        taskId: taskId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Subtask>> createElement() {
    return _SubtasksForTaskProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SubtasksForTaskProvider && other.taskId == taskId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, taskId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SubtasksForTaskRef on AutoDisposeStreamProviderRef<List<Subtask>> {
  /// The parameter `taskId` of this provider.
  String get taskId;
}

class _SubtasksForTaskProviderElement
    extends AutoDisposeStreamProviderElement<List<Subtask>>
    with SubtasksForTaskRef {
  _SubtasksForTaskProviderElement(super.provider);

  @override
  String get taskId => (origin as SubtasksForTaskProvider).taskId;
}

String _$tasksControllerHash() => r'e755c20fb6746219f8b9ee56ddc9632ea04d1a29';

/// See also [TasksController].
@ProviderFor(TasksController)
final tasksControllerProvider =
    AutoDisposeNotifierProvider<TasksController, void>.internal(
      TasksController.new,
      name: r'tasksControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$tasksControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TasksController = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
