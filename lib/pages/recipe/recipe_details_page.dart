import 'package:MyRecipe/config/config_documents.dart';
import 'package:MyRecipe/model/bean_recipe.dart';
import 'package:MyRecipe/pages/recipe/page_recipe_add.dart';
import 'package:MyRecipe/utils/utils_logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Recipe detail page
class RecipeDetailPage extends StatefulWidget {
  final RecipeBean data;

  const RecipeDetailPage({super.key, required this.data});

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  late RecipeBean _data;

  @override
  void initState() {
    _data = widget.data;
    super.initState();
  }

// Refresh the recipe details
  Future<void> _refreshDetail() async {
    try {
      var doc = await FirebaseFirestore.instance
          .collection(DocumentsConfig.recipe)
          .doc(_data.id)
          .get();
      _data = RecipeBean.fromJson(doc.data(), doc.id);
      setState(() {});
    } catch (e) {
      LoggerUtils.e(e);
    }
  }

// Build the recipe details page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFFE9EFF9),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showPopupMenu(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                _data.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                'Introduction:',
                style: TextStyle(
                    color: Color(0xFF0059D8),
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.symmetric(
                  horizontal: 15.0), // Ensures 15px margin on each side
              width: MediaQuery.of(context).size.width -
                  30, // Screen width minus 30px for margins
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4FB), // Specified background color
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(_data.introduce),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                'Duration:',
                style: TextStyle(
                    color: Color(0xFF0059D8),
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                children: [
                  const Icon(Icons.timer, color: Color(0xFF0059D8)),
                  const SizedBox(width: 8),
                  Text(_data.getDuration()),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                'Ingredients:',
                style: TextStyle(
                  color: Color(0xFF0059D8),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            ..._buildIngredientList(),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                'Recipe:',
                style: TextStyle(
                  color: Color(0xFF0059D8),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            ..._buildRecipeSteps(),
          ],
        ),
      ),
    );
  }

// Show the popup menu
  void _showPopupMenu(BuildContext context) async {
    var res = await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.only(top: 40),
          height: 180,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly, // Evenly space the two icons
                children: [
                  InkWell(
                    onTap: () {
                      // Edit operation
                      Navigator.of(context).pop("edit");
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF001F4C),
                            ),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Color(0xFF001F4C),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Edit',
                          style: TextStyle(
                            color: Color(0xFF001F4C),
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      // Delete operation
                      Navigator.of(context).pop("delete");
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF001F4C),
                            ),
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: Color(0xFF001F4C),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text('Delete',
                            style: TextStyle(color: Color(0xFF001F4C))),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF001F4C),
                  minimumSize: const Size(300, 24),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                onPressed: () {
                  Navigator.pop(context); // Close the modal
                },
              ),
            ],
          ),
        );
      },
    );
    if (!context.mounted) return;

    if (res == 'edit') {
      _edit();
    } else if (res == 'delete') {
      _deletePop();
    }
  }

// Build the ingredient list
  List<Widget> _buildIngredientList() {
    return _data.materials
        .map(
          (ingredient) => Container(
            margin: const EdgeInsets.symmetric(
                horizontal: 15.0, vertical: 4.0), // Consistent margin
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            width: MediaQuery.of(context).size.width -
                30, // Dynamic width calculation
            decoration: BoxDecoration(
              color: const Color(
                  0xFFF2F4FB), // Sets the specified light blue background color
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(ingredient.name,
                    style: const TextStyle(
                        color: Colors
                            .black)), // Ensuring text color is explicitly set if needed
                Text(ingredient.dosage, style: TextStyle(color: Colors.black)),
              ],
            ),
          ),
        )
        .toList();
  }

// Build the recipe steps
  List<Widget> _buildRecipeSteps() {
    List<Widget> widgets = [];
    for (var i = 0; i < _data.steps.length; i++) {
      widgets.add(Container(
        margin: const EdgeInsets.symmetric(
            horizontal: 15.0, vertical: 4.0), // Uniform horizontal margin
        padding: const EdgeInsets.all(16.0),
        width: MediaQuery.of(context).size.width - 30, // Adaptive width
        decoration: BoxDecoration(
          color: const Color(
              0xFFF2F4FB), // Light blue background as previously defined
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(
                // fontSize: 16.0,
                color: Colors.black), // Default text style for the description
            children: [
              TextSpan(
                text: 'Step ${i + 1} ', // "Step X" text
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0059D8), // Blue color for "Step X"
                ),
              ),
              TextSpan(
                text: _data.steps[i].desc, // Actual step description
              ),
            ],
          ),
        ),
      ));
    }
    return widgets;
  }

// Edit the recipe, navigate to the recipe add page
  void _edit() async {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      CupertinoPageRoute(
        builder: (ctx) {
          return RecipeAddPage(data: _data);
        },
      ),
    );
  }

// Delete the recipe, show confirmation dialog
  void _deletePop() async {
    if (!mounted) return;
    var res = await showDialog<bool?>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text(
              'Confirm delete of ${_data.title}',
              textAlign:
                  TextAlign.center, // Center the text within the AlertDialog
            ),
            actionsAlignment: MainAxisAlignment
                .center, // Centers the actions within the AlertDialog
            actionsPadding: const EdgeInsets.only(
                bottom: 5), // Adds padding only at the bottom
            actions: <Widget>[
              TextButton(
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Color(0xFF001F4C),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text(
                  'Confirm',
                  style: TextStyle(
                    color: Color(0xFF001F4C),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        });
    if (!mounted) return;
    if (res != null) {
      _deleteData();
    }
  }

// Delete the recipe data
  void _deleteData() async {
    try {
      await FirebaseFirestore.instance
          .collection(DocumentsConfig.recipe)
          .doc(_data.id)
          .delete();
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      LoggerUtils.e(e);
    }
  }
}
