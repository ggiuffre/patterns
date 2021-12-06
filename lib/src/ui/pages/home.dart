import 'package:flutter/material.dart';
import 'package:patterns/src/ui/components/categories_index.dart';

import '../../data/event.dart';
import '../components/custom_app_bar.dart';
import '../components/events_index.dart';
import '../components/patterns_index.dart';
import '../components/settings.dart';

class HomePage extends StatelessWidget {
  final int selectedNavigationItem;
  final void Function(int) onNavigationItemTapped;
  final void Function(String) onCategoryTapped;
  final void Function(Event) onEventTapped;
  final VoidCallback onNewEvent;

  const HomePage({
    Key? key,
    required this.selectedNavigationItem,
    required this.onNavigationItemTapped,
    required this.onCategoryTapped,
    required this.onEventTapped,
    required this.onNewEvent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageToShow = {
      0: EventsIndex(onEventTapped: onEventTapped),
      1: const PatternsIndex(),
      2: const SettingsPage(),
      3: CategoriesIndex(onCategoryTapped: onCategoryTapped),
    };

    return Scaffold(
      appBar: CustomAppBar(
        title: const Text("Home Page"),
        withLogoutAction: true,
      ),
      body: pageToShow.containsKey(selectedNavigationItem) ? pageToShow[selectedNavigationItem] : pageToShow[0],
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).secondaryHeaderColor,
              ),
              child: const Text('Menu'),
            ),
            ListTile(
              selected: selectedNavigationItem == 0,
              title: const Text('All events'),
              leading: const Icon(Icons.notes_rounded),
              onTap: () {
                onNavigationItemTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              selected: selectedNavigationItem == 3,
              title: const Text('Categories'),
              leading: const Icon(Icons.notes_rounded),
              onTap: () {
                onNavigationItemTapped(3);
                Navigator.pop(context);
              },
            ),
            ListTile(
              selected: selectedNavigationItem == 1,
              title: const Text('Patterns'),
              leading: const Icon(Icons.bar_chart),
              onTap: () {
                onNavigationItemTapped(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              selected: selectedNavigationItem == 2,
              title: const Text('Settings'),
              leading: const Icon(Icons.settings),
              onTap: () {
                onNavigationItemTapped(2);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onNewEvent,
        tooltip: 'New event',
        child: const Icon(Icons.add),
      ),
    );
  }
}
