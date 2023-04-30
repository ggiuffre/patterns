import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart' show Logger;
import 'package:patterns/src/data/repositories/event_providers.dart';

import '../../data/event.dart';
import '../../data/similarities.dart';
import '../components/custom_app_bar.dart';
import '../components/error_card.dart';

final _logger = Logger((CategoryDetailsPage).toString());

class CategoryDetailsPage extends ConsumerWidget {
  final String category;

  const CategoryDetailsPage({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: CustomAppBar(title: Text(category), withLogoutAction: true),
        body: ref.watch(eventList).when(
              loading: () =>
                  const Center(child: CircularProgressIndicator.adaptive()),
              error: (error, stackTrace) {
                const message = "Couldn't retrieve events.";
                _logger.severe(message, error, stackTrace);
                return const ErrorCard(text: message);
              },
              data: (events) {
                List<Event> categoryEvents = [];
                Map<String, List<Event>> eventsByCategory = {};
                for (final event in events) {
                  final title = event.title;
                  if (title == category) {
                    categoryEvents.add(event);
                  } else {
                    eventsByCategory.putIfAbsent(title, () => []).add(event);
                  }
                }
                final coefficientsByCategory = eventsByCategory
                    .map(
                      (categoryTitle, otherCategoryEvents) => MapEntry(
                        categoryTitle,
                        similarity(
                          categoryEvents,
                          otherCategoryEvents,
                          binary: true,
                        ),
                      ),
                    )
                    .entries
                    .toList()
                  ..sort((a, b) => b.value.compareTo(a.value));

                final defaultTextColor =
                    Theme.of(context).colorScheme.brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black;
                return coefficientsByCategory.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                            child: Text("No other categories to compare")),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(8.0),
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(),
                        itemCount: coefficientsByCategory.length,
                        itemBuilder: (BuildContext context, int index) {
                          final mapEntry = coefficientsByCategory[index];
                          final coefficient = mapEntry.value;
                          final colorLabel = coefficient.isNaN
                              ? defaultTextColor
                              : HSLColor.fromColor(
                                  Color.lerp(Colors.red, Colors.green,
                                          (coefficient + 1) / 2) ??
                                      Colors.white,
                                ).withLightness(0.75).toColor();
                          return ListTile(
                            title: Text(mapEntry.key),
                            trailing: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  colorLabel, BlendMode.modulate),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: Theme.of(context)
                                              .colorScheme
                                              .brightness ==
                                          Brightness.dark
                                      ? Colors.black
                                      : Colors.white,
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4.0, horizontal: 8.0),
                                child: Text(
                                  coefficient.toStringAsPrecision(3),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: defaultTextColor,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
              },
            ),
      );
}
