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
  final VoidCallback onCategoryEventsTapped;

  const CategoryDetailsPage({Key? key, required this.category, required this.onCategoryEventsTapped}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: CustomAppBar(title: Text(category), withLogoutAction: true),
        body: StreamBuilder<Iterable<Event>>(
          stream: ref.read(eventProvider).sorted(descending: true),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              developer.log(snapshot.error.toString());
              return const ErrorCard(text: "Couldn't retrieve events.");
            }

            if (snapshot.hasData) {
              final events = snapshot.data ?? const Iterable.empty();
              final categoryEvents = events.where((e) => e.title == category);
              final otherEvents = events.where((e) => e.title != category);
              final otherCategories = otherEvents.map((e) => e.title).toSet();
              final coefficients = otherCategories
                  .map((c) => similarity(
                        categoryEvents,
                        otherEvents.where((e) => e.title == c),
                        binary: true,
                      ))
                  .toList()
                ..sort();

              return otherCategories.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: Text("No other categories to compare")),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(8.0),
                      itemCount: otherCategories.length,
                      separatorBuilder: (BuildContext context, int index) => const Divider(),
                      itemBuilder: (BuildContext context, int index) {
                        final coefficient = coefficients[otherCategories.length - 1 - index];
                        final colorLabel = HSLColor.fromColor(
                          Color.lerp(Colors.red, Colors.green, (coefficient + 1) / 2) ?? Colors.white,
                        ).withLightness(0.75).toColor();
                        return ListTile(
                          title: Text(otherCategories.elementAt(index)),
                          trailing: ColorFiltered(
                            colorFilter: ColorFilter.mode(colorLabel, BlendMode.modulate),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: Theme.of(context).colorScheme.brightness == Brightness.dark
                                    ? Colors.black
                                    : Colors.white,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                              child: Text(
                                coefficient.toStringAsPrecision(3),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
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
