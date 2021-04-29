import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LogInScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: EmailLogInForm(),
      );
}

class EmailLogInForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EmailLogInFormState();
}

class _EmailLogInFormState extends State<EmailLogInForm> {
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
                    icon: Icon(Icons.login),
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        await _logIn();
                      }
                    },
                    label: const Text('Log in'),
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

  Future<void> _logIn() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      setState(() => _success = true);
    } on FirebaseAuthException catch (e) {
      if ({'user-not-found', 'wrong-password'}.contains(e.code)) {
        print('Wrong username or password.');
      }
    } catch (e) {
      print(e);
    }
  }
}
