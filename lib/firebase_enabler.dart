import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/theme_mode_provider.dart';
import 'theme.dart';

/// Wrapper that allows any required Firebase service (like authentication or Cloud Firestore) to run.
class FirebaseEnabler extends StatelessWidget {
  final Future<FirebaseApp> _firebaseInitialization = Firebase.initializeApp();
  final Widget child;

  FirebaseEnabler({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) => FutureBuilder<FirebaseApp>(
      future: _firebaseInitialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: context.read(themeModeProvider),
            title: 'Patterns',
            home: const Scaffold(body: Center(child: Text("Couldn't initialize storage."))),
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return child;
        }

        return MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: context.read(themeModeProvider),
          title: 'Patterns',
          home: const Scaffold(body: Center(child: CircularProgressIndicator.adaptive())),
        );
      });
}
