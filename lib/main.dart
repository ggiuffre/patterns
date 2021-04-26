import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'authentication.dart';
import 'theme.dart';
import 'user_data.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(child: FirebaseEnabledApp()));
}

class FirebaseEnabledApp extends StatelessWidget {
  final Future<FirebaseApp> _firebaseInitialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) => FutureBuilder<FirebaseApp>(
      future: _firebaseInitialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.system,
            title: 'Patterns',
            home: const Scaffold(body: Center(child: Text("Couldn't initialize storage."))),
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return Authenticated(child: WithUpToDateSchema(child: PatternsApp()));
        }

        return MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          title: 'Patterns',
          home: const Scaffold(body: Center(child: CircularProgressIndicator.adaptive())),
        );
      });
}
