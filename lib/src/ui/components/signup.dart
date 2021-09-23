import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'constrained_card.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.all(8.0),
        child: EmailRegistrationForm(),
      );
}

enum _AuthState { signedOut, processing, error, signedIn }

class EmailRegistrationForm extends StatefulWidget {
  const EmailRegistrationForm({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EmailRegistrationFormState();
}

class _EmailRegistrationFormState extends State<EmailRegistrationForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  _AuthState _authState = _AuthState.signedOut;
  bool _isPasswordObscured = true;

  @override
  Widget build(BuildContext context) => Form(
        key: _formKey,
        child: ConstrainedCard(
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
                  keyboardType: TextInputType.emailAddress,
                  validator: (String? value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your email address';
                    }
                    if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(value ?? "")) {
                      return 'Please check that the address you entered is correct';
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
                      return 'Please enter a password';
                    }
                    if ((value?.length ?? 0) < 4) {
                      return 'Please enter a slightly longer password';
                    }
                    return null;
                  },
                  obscureText: _isPasswordObscured,
                  autocorrect: false,
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  alignment: Alignment.center,
                  child: _authState == _AuthState.signedOut || _authState == _AuthState.error
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
                if (_authState == _AuthState.signedIn) const Center(child: Text('Successfully registered new user')),
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
      setState(() => _authState = _AuthState.signedIn);
    } else {
      setState(() => _authState = _AuthState.error);
    }
  }
}
