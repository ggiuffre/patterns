import 'package:flutter/material.dart';

import '../../data/event.dart';
import '../components/custom_app_bar.dart';
import '../components/events_index.dart';
import '../components/patterns_index.dart';
import '../components/settings.dart';

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
        appBar: CustomAppBar(
          title: const Text("Home Page"),
          withLogoutAction: true,
        ),
        body: selectedNavigationItem == 0
            ? EventsIndex(onEventTapped: onEventTapped)
            : (selectedNavigationItem == 1 ? const PatternsIndex() : const SettingsPage()),
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
                title: const Text('Events'),
                onTap: () {
                  onNavigationItemTapped(0);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Patterns'),
                onTap: () {
                  onNavigationItemTapped(1);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Settings'),
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
