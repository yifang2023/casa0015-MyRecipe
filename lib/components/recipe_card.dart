import 'package:flutter/material.dart';

class RecipeCard extends StatelessWidget {
  final String imageUrl; // 食谱图片URL
  final String title; // 食谱标题
  final String duration; // 烹饪时间

  // 构造函数，接收必要的参数
  RecipeCard({
    required this.imageUrl,
    required this.title,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // 设置卡片边角为圆角
      ),
      elevation: 4, // 卡片阴影
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(12)), // 图片顶部圆角
            child: Image.network(
              imageUrl,
              height: 160, // 图片高度
              width: double.infinity, // 图片宽度填满卡片
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis, // 文字超出部分显示省略号
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 100, bottom: 8.0),
            child: Text(
              duration,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
