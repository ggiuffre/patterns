import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/category.dart';
import '../../data/event.dart';
import '../../data/repositories/events.dart';
import 'error_card.dart';

class CategoriesIndex extends ConsumerWidget {
  final void Function(String) onCategoryTapped;

  const CategoriesIndex({Key? key, required this.onCategoryTapped})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      FutureBuilder<Iterable<Event>>(
        future: ref.read(eventProvider).sorted(descending: true),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const ErrorCard(text: "Couldn't retrieve events.");
          }

          if (snapshot.hasData) {
            final categories =
                categoriesFromEvents(snapshot.data ?? const Iterable.empty());
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
          }

          return const Center(child: CircularProgressIndicator.adaptive());
        },
      );
}
