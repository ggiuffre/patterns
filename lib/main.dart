import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app.dart';
import 'src/authentication.dart';
import 'src/firebase_enabler.dart';
import 'src/local_preferences_enabler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      child: LocalPreferencesEnabler(
        child: FirebaseEnabler(
          child: AuthenticationGuard(
            child: PatternsApp(),
          ),
        ),
      ),
    ),
  );
}
