import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ingredients Selector',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFE9EFF9), // Set the AppBar background color
          foregroundColor: Colors.black, // Set the AppBar text/icon color
        ),
      ),
      home: IngredientsPage(),
    );
  }
}

class IngredientsPage extends StatefulWidget {
  @override
  _IngredientsPageState createState() => _IngredientsPageState();
}

class _IngredientsPageState extends State<IngredientsPage> {
  List<String> ingredients = ['成分1', '成分2', '成分3', '成分4'];
  Map<String, bool> selectedIngredients = {
    '成分1': false,
    '成分2': false,
    '成分3': false,
    '成分4': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16), // Set the padding
          child: TextButton(
            onPressed: () {
              // Handle cancel
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Handle done
            },
            child: Text('Done', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16, top: 16),
            child: Text(
              'Select ingredients to add:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.fromLTRB(
                  16, 16, 16, 20), // Adjust bottom padding to 20
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 4,
                childAspectRatio: 4,
              ),
              itemCount: ingredients.length,
              itemBuilder: (context, index) {
                String ingredient = ingredients[index];
                return CheckboxListTile(
                  title: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(ingredient),
                  ),
                  value: selectedIngredients[ingredient],
                  onChanged: (bool? value) {
                    setState(() {
                      selectedIngredients[ingredient] = value!;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Color(0xFF001F4C),
                  checkColor: Colors.white,
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () {
                // Add to existing list action
              },
              child: Text('Add to an existing list'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Color(0xFFE9EFF9),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: () {
                // Create a new list action
              },
              child: Text('Create a new list'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Color(0xFFE9EFF9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
