import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:MyRecipe/components/recipe_card.dart';

class Body extends StatelessWidget {
  const Body({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.search,
                color: Colors.blue[500],
              ),
              SizedBox(width: 10),
              Text(
                'Search for recipes',
                style: TextStyle(color: Colors.blue[500]),
              ),
            ],
          ),
        ),
        Categories(),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.8,
            ),
            itemCount: 10,
            itemBuilder: (context, index) {
              return RecipeCard(
                imageUrl: 'https://via.placeholder.com/150',
                title: 'Delicious Pizza',
                duration: '45 min',
              );
            },
          ),
        ),
      ],
    );
  }
}

// Categories widget
class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  List<String> categories = [
    'All',
    'Starters',
    'Main course',
    'Soups',
    'Disserts'
  ];
  // by default first item is selected
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: SizedBox(
        height: 25,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          itemBuilder: (context, index) => buildCategoryItem(index),
        ),
      ),
    );
  }

// build category item
  Widget buildCategoryItem(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        margin: EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: selectedIndex == index ? Colors.blue[50] : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          categories[index],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue[500],
          ),
        ),
      ),
    );
  }
}
