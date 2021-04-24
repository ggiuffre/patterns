import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patterns/data/similarities.dart';

import '../../data/event_provider.dart';

// final categoryProvider = Provider<Set<String>>((ref) => ref.watch(eventProvider).map((e) => e.title).toSet());

class PatternsIndex extends ConsumerWidget {
  const PatternsIndex({Key? key}) : super(key: key);

  @override
  Widget build(context, watch) {
    // final categories = watch(categoryProvider).toList();
    final events = watch(eventProvider).toList();
    final categories = watch(eventProvider).map((e) => e.title).toSet();
    final coefficients = similarities(events, categories).reversed.toList();
    return coefficients.isEmpty
        ? Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: Text("No patterns yet")),
          )
        : ListView.separated(
            padding: const EdgeInsets.all(8.0),
            itemCount: coefficients.length,
            separatorBuilder: (BuildContext context, int index) => const Divider(),
            itemBuilder: (BuildContext context, int index) => ListTile(
              title: Text(
                  "${coefficients[index].coefficient} -- ${coefficients[index].labels.first} && ${coefficients[index].labels.last}"),
              onTap: () => print("tapped ${coefficients[index]}"),
            ),
          );
  }
}
