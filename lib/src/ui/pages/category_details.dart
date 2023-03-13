import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/event.dart';
import '../../data/repositories/events.dart';
import '../../data/similarities.dart';
import '../components/custom_app_bar.dart';
import '../components/error_card.dart';

class CategoryDetailsPage extends ConsumerWidget {
  final String category;

  const CategoryDetailsPage({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: CustomAppBar(title: Text(category), withLogoutAction: true),
        body: FutureBuilder<Iterable<Event>>(
          future: ref.read(eventProvider).list,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              developer.log(snapshot.error.toString());
              return const ErrorCard(text: "Couldn't retrieve events.");
            }

            if (snapshot.hasData) {
              final events = snapshot.data ?? const Iterable.empty();
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
                      child:
                          Center(child: Text("No other categories to compare")),
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
                                color:
                                    Theme.of(context).colorScheme.brightness ==
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
            }

            return const Center(child: CircularProgressIndicator.adaptive());
          },
        ),
      );
}
