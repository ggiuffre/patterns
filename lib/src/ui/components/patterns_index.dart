import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart' show Logger;

import '../../data/repositories/similarity_providers.dart';
import 'error_card.dart';

final _logger = Logger((PatternsIndex).toString());

class PatternsIndex extends ConsumerWidget {
  const PatternsIndex({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(similarityList).when(
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),
          error: (error, stackTrace) {
            const message = "Couldn't retrieve patterns";
            _logger.severe(message, error, stackTrace);
            return const ErrorCard(text: message);
          },
          data: (data) {
            final coefficients = data.toList();
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
                          _logger.info("tapped ${coefficients[index]}"),
                      trailing: Text(coefficients[index]
                          .coefficient
                          .toStringAsPrecision(3)),
                    ),
                  );
          },
        );
  }
}
