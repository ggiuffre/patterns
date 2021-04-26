import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'theme.dart';

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
  Widget build(BuildContext context) => MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        title: 'Patterns',
        home: Scaffold(
          appBar: AppBar(title: const Text("Register to Patterns")),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: EmailRegistrationForm(),
          ),
        ),
      );
}

class EmailRegistrationForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EmailRegistrationFormState();
}

class _EmailRegistrationFormState extends State<EmailRegistrationForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool? _success;
  String _userEmail = '';

  @override
  Widget build(BuildContext context) => Form(
        key: _formKey,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  textInputAction: TextInputAction.next,
                  validator: (String? value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (String? value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  obscureText: true,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  child: TextButton.icon(
                    icon: Icon(Icons.person_add),
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        await _register();
                      }
                    },
                    label: const Text('Register'),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: Text(_success == null
                      ? ''
                      : (_success! ? 'Successfully registered $_userEmail' : 'Registration failed')),
                )
              ],
            ),
          ),
        ),
      );

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    late UserCredential userCredential;
    try {
      userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('An account already exists for this email.');
      }
    } catch (e) {
      print(e);
    }

    final user = userCredential.user;
    if (user != null) {
      setState(() {
        _success = true;
        _userEmail = user.email ?? _userEmail;
      });
    } else {
      _success = false;
    }
  }
}
