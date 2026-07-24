// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_widget_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$homeWidgetServiceHash() => r'56ad112322b69a4f81ca46bcb11bc304a0ddae1e';

/// See also [homeWidgetService].
@ProviderFor(homeWidgetService)
final homeWidgetServiceProvider = Provider<HomeWidgetService>.internal(
  homeWidgetService,
  name: r'homeWidgetServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$homeWidgetServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HomeWidgetServiceRef = ProviderRef<HomeWidgetService>;
String _$homeWidgetSyncHash() => r'a66b6e8a4219cd3fce957df4b046c2c94c44dd3c';

/// Keeps the home screen widget's task snapshot fresh by pushing to it
/// every time [todayTasksProvider] changes, for as long as the app is
/// running. Activated once from [appInitialization] by reading it.
///
/// Copied from [HomeWidgetSync].
@ProviderFor(HomeWidgetSync)
final homeWidgetSyncProvider = NotifierProvider<HomeWidgetSync, void>.internal(
  HomeWidgetSync.new,
  name: r'homeWidgetSyncProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$homeWidgetSyncHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$HomeWidgetSync = Notifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
