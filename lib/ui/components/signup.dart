import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: EmailRegistrationForm(),
      );
}

enum _AuthState { signed_out, processing, error, signed_in }

class EmailRegistrationForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EmailRegistrationFormState();
}

class _EmailRegistrationFormState extends State<EmailRegistrationForm> {
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
                  child: Text("Register for free", style: Theme.of(context).textTheme.headline5),
                ),
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
                          icon: const Icon(Icons.person_add),
                          onPressed: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              await _register();
                            }
                          },
                          label: const Text('Register'),
                        )
                      : const CircularProgressIndicator.adaptive(),
                ),
                if (_authState == _AuthState.error) const Center(child: Text('Registration failed')),
                if (_authState == _AuthState.signed_in) const Center(child: Text('Successfully registered new user')),
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
    setState(() => _authState = _AuthState.processing);
    UserCredential? userCredential;
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

    final user = userCredential?.user;
    if (user != null) {
      setState(() => _authState = _AuthState.signed_in);
    } else {
      setState(() => _authState = _AuthState.error);
    }
  }
}
