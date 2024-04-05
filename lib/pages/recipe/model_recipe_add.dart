// part of 'page_recipe_add.dart';

// class _RecipeMaterialsModel {
//   final TextEditingController left;
//   final TextEditingController right;

//   _RecipeMaterialsModel(this.left, this.right);
// }

part of 'page_recipe_add.dart';

// 自定义的 _RecipeMaterialsModel 类，用于管理菜谱材料输入。
class _RecipeMaterialsModel {
  // 'left' TextEditingController 用于处理材料名称的输入。
  final TextEditingController left;
  // 'right' TextEditingController 用于处理材料数量的输入。
  final TextEditingController right;

  // 类的构造函数，接受两个 TextEditingController 实例。
  // 'left' 代表材料名称的控制器，'right' 代表材料数量的控制器。
  _RecipeMaterialsModel(this.left, this.right);
}

