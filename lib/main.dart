import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderScope;
import 'package:logging/logging.dart' show Logger;

import 'firebase_options.dart';
import 'src/app.dart';

void main() async {
  Logger.root.onRecord.listen((record) => debugPrint(
      '${record.time} ${record.level.name} ${record.loggerName}: ${record.message}'));

  WidgetsFlutterBinding.ensureInitialized();

  final firebaseOptions = DefaultFirebaseOptions.currentPlatform;
  await Firebase.initializeApp(options: firebaseOptions);

  runApp(
    const ProviderScope(
      child: PatternsApp(),
    ),
  );
}
