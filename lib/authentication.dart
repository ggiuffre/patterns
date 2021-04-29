import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:patterns/ui/components/login.dart';

import 'theme.dart';
import 'ui/components/signup.dart';

class Authenticated extends StatelessWidget {
  final Widget child;

  const Authenticated({Key? key, required this.child}) : super(key: key);

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
        themeMode: ThemeMode.system,
        title: 'Patterns',
        home: Scaffold(
          appBar: AppBar(title: const Text("Authenticate")),
          body: ListView(
            children: [
              SignUpScreen(),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(child: Text("or")),
              ),
              LogInScreen(),
            ],
          ),
        ),
      );
}
