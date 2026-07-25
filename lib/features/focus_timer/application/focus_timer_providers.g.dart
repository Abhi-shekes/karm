// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focus_timer_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$focusSessionsRepositoryHash() =>
    r'f6d935c04bc24a93e8defb02bcb6c4bbc9509c94';

/// See also [focusSessionsRepository].
@ProviderFor(focusSessionsRepository)
final focusSessionsRepositoryProvider =
    Provider<FocusSessionsRepository>.internal(
      focusSessionsRepository,
      name: r'focusSessionsRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$focusSessionsRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FocusSessionsRepositoryRef = ProviderRef<FocusSessionsRepository>;
String _$todayFocusSessionsHash() =>
    r'828c4a355c5bce170748493bf4ecedf624ddddfa';

/// See also [todayFocusSessions].
@ProviderFor(todayFocusSessions)
final todayFocusSessionsProvider =
    AutoDisposeStreamProvider<List<FocusSession>>.internal(
      todayFocusSessions,
      name: r'todayFocusSessionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$todayFocusSessionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayFocusSessionsRef =
    AutoDisposeStreamProviderRef<List<FocusSession>>;
String _$focusTimerControllerHash() =>
    r'8bcee7d6afb8437fc39854179bb5fc751abdfa63';

/// Kept alive so a running session survives navigating away from the
/// timer screen — only process death actually stops it (see note below).
///
/// Copied from [FocusTimerController].
@ProviderFor(FocusTimerController)
final focusTimerControllerProvider =
    NotifierProvider<FocusTimerController, FocusTimerState>.internal(
      FocusTimerController.new,
      name: r'focusTimerControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$focusTimerControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FocusTimerController = Notifier<FocusTimerState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
