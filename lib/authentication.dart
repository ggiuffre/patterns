import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

class Authenticated extends StatelessWidget {
  final Widget child;

  const Authenticated({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) => snapshot.data == null ? SignUpScreen() : child,
      );
}

class SignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [],
      ),
    );
  }
}
