import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'theme.dart';

class WithUpToDateSchema extends StatelessWidget {
  final events = FirebaseFirestore.instance.collection('events');
  final user = FirebaseAuth.instance.currentUser;
  final Widget child;

  WithUpToDateSchema({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: _hasUpToDateSchema(),
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
            return child;
          }

          return MaterialApp(
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.system,
            title: 'Patterns',
            home: const Scaffold(body: Center(child: CircularProgressIndicator.adaptive())),
          );
        },
      );

  Future<void> _hasUpToDateSchema() async {
    if (user != null) {
      final hasSchema =
          await events.doc(user!.uid).get().then((snapshot) => snapshot.data()?.keys.contains("events") ?? false);
      if (!hasSchema) {
        await _setUpUserData(user!);
      }
    }
  }

  Future<void> _setUpUserData(User user) => events
      .doc(user.uid)
      .set({'events': []})
      .then((value) => print("Added empty event list for user ${user.uid}"))
      .catchError((error) => print("Failed to set up empty event list for user ${user.uid}: $error"));
}
