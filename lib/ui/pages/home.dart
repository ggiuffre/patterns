import 'package:flutter/material.dart';
import 'package:patterns/ui/pages/settings.dart';

import '../../data/event.dart';
import '../components/events_index.dart';
import '../components/patterns_index.dart';

class HomePage extends StatelessWidget {
  final int selectedNavigationItem;
  final void Function(int) onNavigationItemTapped;
  final void Function(Event) onEventTapped;
  final VoidCallback onNewEvent;

  const HomePage({
    Key? key,
    required this.selectedNavigationItem,
    required this.onNavigationItemTapped,
    required this.onEventTapped,
    required this.onNewEvent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("Home Page"),
        ),
        body: selectedNavigationItem == 0
            ? EventsIndex(onEventTapped: onEventTapped)
            : (selectedNavigationItem == 1 ? const PatternsIndex() : const SettingsPage()),
        floatingActionButton: FloatingActionButton(
          onPressed: onNewEvent,
          tooltip: 'New event',
          child: const Icon(Icons.add),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedNavigationItem,
          onTap: onNavigationItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: "Events",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: "Patterns",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Settings",
            ),
          ],
        ),
      );
}
