import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/app_settings_provider.dart';
import 'theme.dart';
import 'ui/components/custom_app_bar.dart';
import 'ui/components/login.dart';
import 'ui/components/signup.dart';

class SignUpLogInSelector extends ConsumerWidget {
  const SignUpLogInSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ref.read(appSettingsProvider).themeMode,
        title: 'Patterns',
        home: Scaffold(
          appBar: CustomAppBar(title: const Text("Authenticate")),
          body: ListView(
            children: [
              const SignUpScreen(),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680.0),
                  child: const _OrText(),
                ),
              ),
              const LogInScreen(),
            ],
          ),
        ),
      );
}

class _OrText extends StatelessWidget {
  const _OrText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 64.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Divider(),
            ColoredBox(
              color: Theme.of(context).canvasColor,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Text("or"),
              ),
            ),
          ],
        ),
      );
}
