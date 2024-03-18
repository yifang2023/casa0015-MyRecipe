import 'package:flutter/material.dart';
import 'package:MyRecipe/components/recipe_body_page.dart';
import 'package:MyRecipe/pages/add_recipe_page.dart';

class RecipePage extends StatelessWidget {
  const RecipePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: Body(),
    );
  }
}

AppBar buildAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.grey[100],
    title: const Text(
        'Recipe Page'), //Image.asset('assets/images/logo.png', width: 100),
    centerTitle: true,
    actions: [
      IconButton(
        icon: const Icon(Icons.add),
        onPressed: () {
          //待添加页面方法
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddRecipePage()),
          );
        },
      ),
    ],
  );
}
