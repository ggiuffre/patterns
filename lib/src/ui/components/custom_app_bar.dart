import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends AppBar {
  CustomAppBar({
    Key? key,
    Widget? leading,
    required Widget title,
    bool withLogoutAction = false,
  }) : super(
          key: key,
          leading: leading,
          title: title,
          actions: [
            if (withLogoutAction)
              PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: TextButton.icon(
                      onPressed: FirebaseAuth.instance.signOut,
                      icon: const Icon(Icons.logout),
                      label: Text(
                          "Log out ${FirebaseAuth.instance.currentUser?.email}"),
                    ),
                  ),
                ],
              ),
          ],
        );
}
