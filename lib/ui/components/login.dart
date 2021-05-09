import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LogInScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: EmailLogInForm(),
      );
}

enum _AuthState { signed_out, processing, error, signed_in }

class EmailLogInForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EmailLogInFormState();
}

class _EmailLogInFormState extends State<EmailLogInForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  _AuthState _authState = _AuthState.signed_out;
  bool _isPasswordObscured = true;

  @override
  Widget build(BuildContext context) => Form(
        key: _formKey,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text("Log in", style: Theme.of(context).textTheme.headline5),
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  validator: (String? value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordObscured ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
                    ),
                  ),
                  validator: (String? value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  obscureText: _isPasswordObscured,
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  alignment: Alignment.center,
                  child: _authState == _AuthState.signed_out || _authState == _AuthState.error
                      ? TextButton.icon(
                          icon: const Icon(Icons.login),
                          onPressed: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              await _logIn();
                            }
                          },
                          label: const Text('Log in'),
                        )
                      : const CircularProgressIndicator.adaptive(),
                ),
                if (_authState == _AuthState.error) const Center(child: Text('Login failed')),
                if (_authState == _AuthState.signed_in) const Center(child: Text('Successfully logged in')),
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
    setState(() => _authState = _AuthState.processing);
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      setState(() => _authState = _AuthState.signed_in);
    } on FirebaseAuthException catch (e) {
      if ({'user-not-found', 'wrong-password'}.contains(e.code)) {
        print('Wrong username or password.');
      }
      setState(() => _authState = _AuthState.error);
    } catch (e) {
      print(e);
      setState(() => _authState = _AuthState.error);
    }
  }
}
