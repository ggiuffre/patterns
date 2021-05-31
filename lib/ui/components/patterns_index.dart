import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/event.dart';
import '../../data/repositories/events.dart';
import '../../data/similarities.dart';
import 'error_card.dart';

class PatternsIndex extends ConsumerWidget {
  const PatternsIndex({Key? key}) : super(key: key);

  @override
  Widget build(context, watch) => StreamBuilder<Iterable<Event>>(
        stream: context.read(eventProvider).sorted(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const ErrorCard(text: "Couldn't retrieve events needed to extract patterns.");
          }

          if (snapshot.hasData) {
            final events = snapshot.data?.toList() ?? [];
            final categories = events.map((e) => e.title).toSet();
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
                      title: Text("${coefficients[index].labels.first} && ${coefficients[index].labels.last}"),
                      onTap: () => print("tapped ${coefficients[index]}"),
                      trailing: Text(coefficients[index].coefficient.toString()),
                    ),
                  );
          }

          return const Center(child: CircularProgressIndicator.adaptive());
        },
      );
}
