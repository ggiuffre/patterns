import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

import '../components/custom_app_bar.dart';

class CustomScaffold extends StatelessWidget {
  final Widget body;
  final String appBarTitle;
  final bool withLogoutAction;
  final bool withDrawerMenu;
  final bool withFloatingActionButton;

  const CustomScaffold({
    Key? key,
    required this.body,
    this.appBarTitle = "Home Page",
    this.withLogoutAction = true,
    this.withDrawerMenu = true,
    this.withFloatingActionButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentPath = Routemaster.of(context).currentRoute.path;
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(appBarTitle),
        withLogoutAction: withLogoutAction,
      ),
      body: body,
      drawer: withDrawerMenu
          ? Drawer(
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
                    selected: currentPath == '/events',
                    title: const Text('All events'),
                    leading: const Icon(Icons.notes_rounded),
                    onTap: () => currentPath != '/events'
                        ? Routemaster.of(context).push('/events')
                        : null,
                  ),
                  ListTile(
                    selected: currentPath == '/categories',
                    title: const Text('Categories'),
                    leading: const Icon(Icons.notes_rounded),
                    onTap: () => currentPath != '/categories'
                        ? Routemaster.of(context).push('/categories')
                        : null,
                  ),
                  ListTile(
                    selected: currentPath == '/patterns',
                    title: const Text('Patterns'),
                    leading: const Icon(Icons.bar_chart),
                    onTap: () => currentPath != '/patterns'
                        ? Routemaster.of(context).push('/patterns')
                        : null,
                  ),
                  ListTile(
                    selected: currentPath == '/settings',
                    title: const Text('Settings'),
                    leading: const Icon(Icons.settings),
                    onTap: () => currentPath != '/settings'
                        ? Routemaster.of(context).push('/settings')
                        : null,
                  ),
                ],
              ),
            )
          : null,
      floatingActionButton: withFloatingActionButton
          ? FloatingActionButton(
              onPressed: () => Routemaster.of(context).push('/new-event'),
              tooltip: 'New event',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
