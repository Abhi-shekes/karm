import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/design/app_colors.dart';
import '../core/design/app_text_styles.dart';
import '../core/design/app_theme.dart';
import '../features/auth/application/auth_providers.dart';
import '../features/auth/presentation/sign_in_screen.dart';
import 'app_initialization.dart';
import 'router.dart';
import 'theme_mode_provider.dart';

class KarmApp extends ConsumerWidget {
  const KarmApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appThemeModeProvider);

    return MaterialApp.router(
      title: 'Karm',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: appRouter,
      builder: (context, child) => _AuthGate(child: child),
    );
  }
}

/// Shows sign-in until a user is authenticated, then gates the real app
/// behind [appInitializationProvider] (seeds a default list, starts the
/// reminder service) before showing the router's output.
class _AuthGate extends ConsumerWidget {
  final Widget? child;

  const _AuthGate({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      data: (user) {
        if (user == null) return const _Scaffolded(child: SignInScreen());
        return _InitializedApp(userId: user.uid, child: child);
      },
      loading: () => const _Scaffolded(child: _LoadingSplash()),
      error: (error, _) => _Scaffolded(child: _ErrorSplash(error: error)),
    );
  }
}

class _InitializedApp extends ConsumerWidget {
  final String userId;
  final Widget? child;

  const _InitializedApp({required this.userId, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final init = ref.watch(appInitializationProvider(userId));
    return init.when(
      data: (_) => child ?? const SizedBox.shrink(),
      loading: () => const _Scaffolded(child: _LoadingSplash()),
      error: (error, _) => _Scaffolded(child: _ErrorSplash(error: error)),
    );
  }
}

class _Scaffolded extends StatelessWidget {
  final Widget child;

  const _Scaffolded({required this.child});

  @override
  Widget build(BuildContext context) => Scaffold(body: child);
}

class _LoadingSplash extends StatelessWidget {
  const _LoadingSplash();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(child: CircularProgressIndicator(color: colors.indigo));
  }
}

class _ErrorSplash extends StatelessWidget {
  final Object error;

  const _ErrorSplash({required this.error});

  @override
  Widget build(BuildContext context) {
    final type = context.textStyles;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Something went wrong: $error',
          style: type.taskNotes,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
