import 'package:flutter/material.dart';

/// Material design card with a maximum width of 680px.
class ConstrainedCard extends StatelessWidget {
  final Widget child;

  const ConstrainedCard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680.0),
        child: Card(child: child),
      );
}
