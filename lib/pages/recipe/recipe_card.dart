part of 'recipe_page.dart';

class RecipeCard extends StatelessWidget {
  final RecipeBean data;

  const RecipeCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // 设置卡片边角为圆角。
      ),
      elevation: 4, // 卡片阴影。
      color: Color(0xFFF2F4FB), // 设置卡片的背景颜色。
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12)), // 图片顶部圆角。
            child: Image.network(
              data.coverUrl,
              height: 130, // 图片高度。
              width: double.infinity, // 图片宽度填满卡片。
              fit: BoxFit.cover,
            ),
            // child: Expanded(
            //   child: Image.network(
            //     data.coverUrl,
            //     fit: BoxFit
            //         .cover, // Image will cover the entire space of the container.
            //   ),
            // ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                data.title, // 卡片标题。
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF001F4C), // 设置标题颜色。
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis, // 文字超出部分显示省略号。
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 80, bottom: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min, // 确保 Row 的大小仅足以包含图标和文本。
              children: <Widget>[
                Icon(Icons.access_time,
                    color: Colors.grey, size: 14), // 添加时钟图标。
                SizedBox(width: 4), // 在图标和文本之间添加一些间隔。
                Text(
                  data.getDuration(), // 烹饪时长显示。
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
