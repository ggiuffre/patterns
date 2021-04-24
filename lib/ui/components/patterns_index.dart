import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/event_provider.dart';

// final categoryProvider = Provider<Set<String>>((ref) => ref.watch(eventProvider).map((e) => e.title).toSet());

class PatternsIndex extends ConsumerWidget {
  const PatternsIndex({Key? key}) : super(key: key);

  @override
  Widget build(context, watch) {
    // final categories = watch(categoryProvider).toList();
    final categories = watch(eventProvider).map((e) => e.title).toSet().toList();
    categories.sort();
    return categories.isEmpty
        ? Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: Text("No patterns to display yet")),
          )
        : ListView.separated(
            padding: const EdgeInsets.all(8.0),
            itemCount: categories.length,
            separatorBuilder: (BuildContext context, int index) => const Divider(),
            itemBuilder: (BuildContext context, int index) => ListTile(
              title: Text(categories[index]),
              onTap: () => print("tapped ${categories[index]}"),
            ),
          );
  }
}
