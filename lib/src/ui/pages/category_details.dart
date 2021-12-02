import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/constrained_card.dart';
import '../components/custom_app_bar.dart';

class CategoryDetailsPage extends ConsumerWidget {
  final String category;

  const CategoryDetailsPage({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: CustomAppBar(title: Text(category), withLogoutAction: true),
        body: ListView(
          padding: const EdgeInsets.all(8.0),
          children: [
            ConstrainedCard(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(category),
              ),
            ),
            ConstrainedCard(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton.icon(
                  onPressed: () async {
                    // navigate to (filtered) events index...
                  },
                  icon: const Icon(Icons.list),
                  label: const Text("See events"),
                ),
              ),
            ),
          ],
        ),
      );
}
