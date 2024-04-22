import 'package:MyRecipe/config/config_documents.dart';
import 'package:MyRecipe/model/bean_recipe.dart';
import 'package:MyRecipe/pages/recipe/page_recipe_add.dart';
import 'package:MyRecipe/utils/utils_logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFFE9EFF9),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // 返回上一个页面
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
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: const Text(
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
              child: Text(
                  _data.introduce), // Assuming you have a child text widget
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: const Text(
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
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: const Text(
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
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: const Text(
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

  void _showPopupMenu(BuildContext context) async {
    var res = await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.only(top: 40), // 顶部增加一些padding
          height: 180, // 增加弹窗的高度以适应顶部的padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // 调整为从顶部开始
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 图标均匀分布
                children: [
                  InkWell(
                    onTap: () {
                      // 编辑操作
                      Navigator.of(context).pop("edit");
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8), // 图标内部的padding
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, // 使容器成为圆形
                            border: Border.all(
                              color: const Color(0xFF001F4C), // 边框颜色为深蓝色
                            ),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Color(0xFF001F4C),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // 增加图标和文字之间的间距（8像素）（可根据需要调整）(
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
                      // 删除操作
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
                        const SizedBox(height: 8), // 增加图标和文字之间的间距
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
                  backgroundColor: const Color(0xFF001F4C), // 设置按钮背景颜色
                  minimumSize: const Size(300, 24), // 指定按钮的最小尺寸，这里设置宽度为200像素
                  padding:
                      const EdgeInsets.symmetric(vertical: 12), // 设置按钮的垂直内边距
                ),
                child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                onPressed: () {
                  Navigator.pop(context); // 关闭弹窗
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
                    style: TextStyle(
                        color: Colors
                            .black)), // Ensuring text color is explicitly set if needed
                Text(ingredient.dosage, style: TextStyle(color: Colors.black)),
              ],
            ),
          ),
        )
        .toList();
  }

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
            style: TextStyle(
                fontSize: 16.0,
                color: Colors.black), // Default text style for the description
            children: [
              TextSpan(
                text: 'Step ${i + 1} ', // "Step X" text
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0059D8), // Blue color for "Step X"
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
