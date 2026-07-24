import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:karm/core/design/app_theme.dart';
import 'package:karm/features/auth/presentation/sign_in_screen.dart';

void main() {
  testWidgets('Sign-in screen renders title and Google button', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AppTheme.light(), home: const SignInScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Karm'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });
}
