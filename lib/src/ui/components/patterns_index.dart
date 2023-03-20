import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/similarities.dart';
import '../../data/similarities.dart';
import 'error_card.dart';

class PatternsIndex extends ConsumerWidget {
  const PatternsIndex({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(similarityProvider).when(
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),
          error: (error, stackTrace) {
            developer.log(
              "Couldn't retrieve events needed to extract patterns.",
              error: error,
              stackTrace: stackTrace,
            );
            return const ErrorCard(
                text: "Couldn't retrieve events needed to extract patterns.");
          },
          data: (repo) => FutureBuilder<List<Similarity>>(
            future: repo.list(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                developer.log(snapshot.error.toString());
                return const ErrorCard(
                    text: "Couldn't retrieve patterns from events.");
              }

              if (snapshot.hasData) {
                final coefficients = snapshot.data ?? [];
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
                        itemBuilder: (BuildContext context, int index) =>
                            ListTile(
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
          ),
        );
  }
}
