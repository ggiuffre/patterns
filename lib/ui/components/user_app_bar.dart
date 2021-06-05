import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserAppBar extends AppBar {
  UserAppBar({Key? key, required Widget title})
      : super(
          key: key,
          title: title,
          brightness: Brightness.dark,
          actions: [
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: TextButton.icon(
                    onPressed: FirebaseAuth.instance.signOut,
                    icon: const Icon(Icons.logout),
                    label: Text("Log out ${FirebaseAuth.instance.currentUser?.email}"),
                  ),
                ),
              ],
            ),
          ],
        );
}

// TODO: UserAppBar should not show a logout button if a user is authenticated with an anonymous session.

// TODO remove explicit `brightness: Brightness.dark` setting once Flutter AppBar sets its brightness automatically (or we have a proper palette)
