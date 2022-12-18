import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

import '../components/categories_index.dart';
import 'custom_scaffold.dart';

class CategoriesIndexPage extends StatelessWidget {
  const CategoriesIndexPage({super.key});

  @override
  Widget build(BuildContext context) => CustomScaffold(
        body: CategoriesIndex(
          onCategoryTapped: (category) =>
              Routemaster.of(context).push(category),
        ),
      );
}
