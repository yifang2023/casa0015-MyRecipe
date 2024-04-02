import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class RecipeDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFE9EFF9),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // 返回上一个页面
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_vert),
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
                'Chicken Curry',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 15),
            Text(
              'Introduction:',
              style: TextStyle(
                  color: Color(0xFF0059D8), fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text('好好吃呢'),
            ),
            SizedBox(height: 16),
            Text(
              'Duration:',
              style: TextStyle(
                  color: Color(0xFF0059D8), fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.timer, color: Color(0xFF0059D8)),
                SizedBox(width: 8),
                Text('1hr 20min'),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Ingredients:',
              style: TextStyle(
                  color: Color(0xFF0059D8), fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ..._buildIngredientList(),
            SizedBox(height: 16),
            Text(
              'Recipe:',
              style: TextStyle(
                  color: Color(0xFF0059D8), fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ..._buildRecipeSteps(),
          ],
        ),
      ),
    );
  }

// 顶部菜单弹窗
  void _showPopupMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.only(top: 40), // 顶部增加一些padding
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
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8), // 图标内部的padding
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, // 使容器成为圆形
                            border: Border.all(
                              color: Color(0xFF001F4C), // 边框颜色为深蓝色
                            ),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Color(0xFF001F4C),
                          ),
                        ),
                        SizedBox(height: 8), // 增加图标和文字之间的间距（8像素）（可根据需要调整）(
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
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Color(0xFF001F4C),
                            ),
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: Color(0xFF001F4C),
                          ),
                        ),
                        SizedBox(height: 8), // 增加图标和文字之间的间距
                        const Text('Delete',
                            style: TextStyle(color: Color(0xFF001F4C))),
                      ],
                    ),
                  ),
                ],
              ),
              Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xFF001F4C), // 设置按钮背景颜色
                  minimumSize: Size(300, 24), // 指定按钮的最小尺寸，这里设置宽度为200像素
                  padding: EdgeInsets.symmetric(vertical: 12), // 设置按钮的垂直内边距
                ),
                child: Text('Cancel', style: TextStyle(fontSize: 16)),
                onPressed: () {
                  Navigator.pop(context); // 关闭弹窗
                },
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildIngredientList() {
    // Dummy ingredients data
    List<Map<String, dynamic>> ingredients = [
      {"name": "鸡肉", "quantity": "500g"},
      {"name": "土豆", "quantity": "2个"}
    ];

    return ingredients
        .map(
          (ingredient) => Container(
            margin: const EdgeInsets.only(bottom: 8.0),
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(ingredient['name']),
                Text(ingredient['quantity']),
              ],
            ),
          ),
        )
        .toList();
  }

  List<Widget> _buildRecipeSteps() {
    // Dummy steps data
    List<String> steps = ["摘肉", "下锅"];

    return steps
        .asMap()
        .entries
        .map(
          (step) => Container(
            margin: const EdgeInsets.only(bottom: 8.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text('Step ${step.key + 1} ${step.value}'),
          ),
        )
        .toList();
  }
}
