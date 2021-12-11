import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firebase_options.dart';
import 'data/app_settings_provider.dart';
import 'theme.dart';
import 'ui/components/error_card.dart';

/// Wrapper that allows any required Firebase service (like authentication or Cloud Firestore) to run.
class FirebaseEnabler extends ConsumerWidget {
  final Future<FirebaseApp> _firebaseInitialization = Firebase.initializeApp(
    options: Platform.isLinux ? null : DefaultFirebaseOptions.currentPlatform,
  );
  final Widget child;

  FirebaseEnabler({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) => FutureBuilder<FirebaseApp>(
        future: _firebaseInitialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return MaterialApp(
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: ref.read(appSettingsProvider).themeMode,
              title: 'Patterns',
              home: const Scaffold(body: ErrorCard(text: "Couldn't initialize storage.")),
            );
          }

          if (snapshot.connectionState == ConnectionState.done) {
            return child;
          }

          return MaterialApp(
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ref.read(appSettingsProvider).themeMode,
            title: 'Patterns',
            home: const Scaffold(body: Center(child: CircularProgressIndicator.adaptive())),
          );
        },
      );
}
