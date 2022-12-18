import 'package:flutter/material.dart';

import '../components/patterns_index.dart';
import 'custom_scaffold.dart';

class PatternsIndexPage extends StatelessWidget {
  const PatternsIndexPage({super.key});

  @override
  Widget build(BuildContext context) =>
      const CustomScaffold(body: PatternsIndex());
}
