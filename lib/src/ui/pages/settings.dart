import 'package:flutter/material.dart';

import '../components/settings.dart';
import 'custom_scaffold.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => const CustomScaffold(
        body: SettingsView(),
      );
}
