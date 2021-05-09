import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserAppBar extends AppBar {
  UserAppBar({Key? key, required Widget title})
      : super(
          key: key,
          title: title,
          actions: [
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: TextButton.icon(
                    onPressed: FirebaseAuth.instance.signOut,
                    icon: const Icon(Icons.logout),
                    label: const Text("Log out"),
                  ),
                ),
              ],
            ),
          ],
        );
}

// TODO: UserAppBar should not show a logout button if a user is authenticated with an anonymous session.
