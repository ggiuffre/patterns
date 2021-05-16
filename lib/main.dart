import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'authentication.dart';
import 'firebase_enabler.dart';
import 'local_preferences_enabler.dart';

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
