import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(child: FirebaseEnabledApp()));
}

class FirebaseEnabledApp extends StatelessWidget {
  final Future<FirebaseApp> _firebaseInitialization = Firebase.initializeApp();

  static final theme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.brown,
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
    }),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.brown,
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
    }),
  );

  @override
  Widget build(BuildContext context) => FutureBuilder<FirebaseApp>(
      future: _firebaseInitialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            theme: theme,
            darkTheme: darkTheme,
            themeMode: ThemeMode.system,
            title: 'Patterns',
            home: const Scaffold(body: Center(child: Text("Couldn't initialize storage."))),
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return PatternsApp(theme: theme, darkTheme: darkTheme);
        }

        return MaterialApp(
          theme: theme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.system,
          title: 'Patterns',
          home: const Scaffold(body: Center(child: CircularProgressIndicator.adaptive())),
        );
      });
}
