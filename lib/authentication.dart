import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/theme_mode_provider.dart';
import 'theme.dart';
import 'ui/components/login.dart';
import 'ui/components/signup.dart';

/// Wrapper that only shows its child if a user is authenticated, and otherwise prompts for authentication.
class AuthenticationGuard extends StatelessWidget {
  final Widget child;

  const AuthenticationGuard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) => snapshot.data == null ? SignUpLogInSelector() : child,
      );
}

class SignUpLogInSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: context.read(themeModeProvider),
        title: 'Patterns',
        home: Scaffold(
          appBar: AppBar(title: const Text("Authenticate")),
          body: ListView(
            children: [
              SignUpScreen(),
              const _OrText(),
              LogInScreen(),
            ],
          ),
        ),
      );
}

class _OrText extends StatelessWidget {
  const _OrText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 64.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Divider(),
            ColoredBox(
              color: Theme.of(context).canvasColor,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Text("or"),
              ),
            ),
          ],
        ),
      );
}
