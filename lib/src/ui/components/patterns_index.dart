import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/category.dart';
import '../../data/event.dart';
import '../../data/repositories/events.dart';
import '../../data/similarities.dart';
import 'error_card.dart';

class PatternsIndex extends ConsumerWidget {
  const PatternsIndex({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      FutureBuilder<Iterable<Event>>(
        future: ref.read(eventProvider).list,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            developer.log(snapshot.error.toString());
            return const ErrorCard(
                text: "Couldn't retrieve events needed to extract patterns.");
          }

          if (snapshot.hasData) {
            final categories =
                categoriesFromEvents(snapshot.data ?? const Iterable.empty());
            int maxNumCategories = 10;
            final topCategories = categories.takeWhile(
                (category) => maxNumCategories-- >= 0 && category.count > 1);
            final categoryTitles = topCategories.map((c) => c.title).toSet();
            final events =
                snapshot.data?.where((e) => categoryTitles.contains(e.title)) ??
                    const Iterable.empty();
            final coefficients = similarities(events).reversed.toList();
            return coefficients.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(child: Text("No patterns yet")),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: coefficients.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(),
                    itemBuilder: (BuildContext context, int index) => ListTile(
                      title: Text(
                          "${coefficients[index].labels.first} && ${coefficients[index].labels.last}"),
                      onTap: () =>
                          developer.log("tapped ${coefficients[index]}"),
                      trailing: Text(coefficients[index]
                          .coefficient
                          .toStringAsPrecision(3)),
                    ),
                  );
          }

          return const Center(child: CircularProgressIndicator.adaptive());
        },
      );
}
