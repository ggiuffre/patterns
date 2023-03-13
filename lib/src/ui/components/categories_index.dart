import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
            final events = snapshot.data?.toList() ?? [];
            final categories = events.map((e) => e.title).toSet().toList();
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
                    itemBuilder: (BuildContext context, int index) => ListTile(
                      title: Text(categories[index]),
                      onTap: () => onCategoryTapped(categories[index]),
                      trailing: Text(
                          "${events.where((e) => e.title == categories[index]).length} events"),
                    ),
                  );
          }

          return const Center(child: CircularProgressIndicator.adaptive());
        },
      );
}
