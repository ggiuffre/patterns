import 'package:flutter/material.dart';

import '../components/error_card.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text("Page not found")),
        body: const ErrorCard(text: "Error 404: the page you requested could not be found."),
      );
}
