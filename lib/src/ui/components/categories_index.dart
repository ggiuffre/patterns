import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart' show Logger;
import 'package:patterns/src/data/repositories/event_providers.dart';

import '../../data/category.dart';
import 'error_card.dart';

final _logger = Logger((CategoriesIndex).toString());

class CategoriesIndex extends ConsumerWidget {
  final void Function(String) onCategoryTapped;

  const CategoriesIndex({Key? key, required this.onCategoryTapped})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ref.watch(sortedEventList).when(
            loading: () =>
                const Center(child: CircularProgressIndicator.adaptive()),
            error: (error, stackTrace) {
              const message = "Couldn't retrieve events";
              _logger.severe(message, error, stackTrace);
              return const ErrorCard(text: message);
            },
            data: (data) {
              final categories = categoriesFromEvents(data);
              return categories.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: Text("No categories yet")),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: categories.length,
                      separatorBuilder: (BuildContext context, int index) =>
                          const Divider(),
                      itemBuilder: (context, index) => ListTile(
                        title: Text(categories.elementAt(index).title),
                        onTap: () =>
                            onCategoryTapped(categories.elementAt(index).title),
                        trailing:
                            Text("${categories.elementAt(index).count} events"),
                      ),
                    );
            },
          );
}
