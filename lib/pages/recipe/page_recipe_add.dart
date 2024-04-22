import 'dart:io';

import 'package:MyRecipe/config/config_documents.dart';
import 'package:MyRecipe/model/bean_recipe.dart';
import 'package:MyRecipe/pages/recipe/edit/edit_ingredients_page.dart';
import 'package:MyRecipe/pages/recipe/edit/edit_recipe_page.dart';
import 'package:MyRecipe/utils/utils_logger.dart';
import 'package:MyRecipe/utils/utils_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

// 引入一个局部文件，该文件定义了添加菜谱时需要的模型
part 'model_recipe_add.dart';

// 定义RecipeAddPage类，它是一个有状态的小部件（StatefulWidget），用于添加或编辑菜谱
class RecipeAddPage extends StatefulWidget {
  final RecipeBean? data;

  const RecipeAddPage({super.key, this.data});

  @override
  State<RecipeAddPage> createState() => _RecipeAddPageState();
}

// 定义内部的State类，用于管理状态和事件处理
class _RecipeAddPageState extends State<RecipeAddPage> {
  final ImagePicker _picker = ImagePicker();

  // 文本控制器，用于获取用户输入的文本
  late TextEditingController _titleTextEditingController;
  late TextEditingController _introduceTextEditingController;
  String _coverUrl = ""; // 菜谱封面图片的URL
  List<_RecipeMaterialsModel> _materials = []; // 存储食材信息的列表
  RecipeClassifyBean? _classify; // 分类信息
  List<TextEditingController> _steps = []; // 存储步骤信息的控制器列表
  final List<RecipeClassifyBean> _list = []; // 分类信息列表

  late ValueNotifier<Duration> _durationValueNotifier;

  // 新增显示时长选择器的方法
  // 选择器包括两个文本框，分别用于输入小时和分钟
  Future<void> _showDurationPicker(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return SizedBox(
          height: MediaQuery.of(context).copyWith().size.height / 3,
          child: CupertinoTimerPicker(
            initialTimerDuration: _durationValueNotifier.value,
            mode: CupertinoTimerPickerMode.hm, // 时和分
            onTimerDurationChanged: (Duration changedtimer) {
              _durationValueNotifier.value = changedtimer;
            },
          ),
        );
      },
    );
  }

  // 提交用户输入的菜谱数据到数据库的方法
  // 检查封面图片URL、标题、简介、时长、分类和步骤是否为空，如果为空则不提交
  // 如果检查通过，则构造一个新的RecipeBean对象，并根据是新增还是更新操作将数据提交到数据库
  void _submitData(BuildContext context) {
    if (_coverUrl.isEmpty) {
      ToastUtils.show("Please select cover image");
      return;
    }
    var title = _titleTextEditingController.text;
    if (title.isEmpty) {
      ToastUtils.show("Please input title");
      return;
    }
    var introduce = _introduceTextEditingController.text;
    if (introduce.isEmpty) {
      ToastUtils.show("Please input introduction");
      return;
    }
    var duration = _durationValueNotifier.value;
    if (duration.inMinutes == 0) {
      ToastUtils.show("Please select duration");
      return;
    }
    if (_classify == null) {
      ToastUtils.show("Please select category");
      return;
    }
    var classifyName = _classify?.name ?? "";
    var classifyCode = _classify?.code ?? "";
    var temp1 = _steps.map((e) => RecipeStepBean(e.text)).toList();
    List<RecipeStepBean> steps = [];
    for (var value in temp1) {
      if (value.desc.isNotEmpty) {
        steps.add(value);
      }
    }
    if (steps.isEmpty) {
      ToastUtils.show("Please input steps");
      return;
    }

    var temp2 = _materials
        .map((e) => RecipeMaterialsBean(e.left.text, e.right.text))
        .toList();
    List<RecipeMaterialsBean> materials = [];
    for (var value in temp2) {
      if (value.name.isNotEmpty && value.dosage.isNotEmpty) {
        materials.add(value);
      }
    }
    if (materials.isEmpty) {
      ToastUtils.show("Please input ingredients");
      return;
    }
    var tempData = widget.data?.id;
    var submitData = RecipeBean(
      tempData ?? "",
      title,
      _coverUrl,
      introduce,
      classifyName,
      classifyCode,
      duration.inHours,
      duration.inMinutes % 60,
      materials,
      steps,
      DateTime.now().millisecondsSinceEpoch,
      DocumentsConfig.userId,
    );
    if (tempData == null) {
      FirebaseFirestore.instance
          .collection(DocumentsConfig.recipe)
          .add(submitData.toJson())
          .then((value) {
        LoggerUtils.i("add success");
        Navigator.of(context).pop(true);
      }).catchError((e) {
        LoggerUtils.e(e);
      });
    } else {
      FirebaseFirestore.instance
          .collection(DocumentsConfig.recipe)
          .doc(tempData)
          .update(submitData.toJson())
          .then((value) {
        LoggerUtils.i("update success");
        Navigator.of(context).pop(true);
      }).catchError((e) {
        LoggerUtils.e(e);
      });
    }
  }

  // 初始化文本控制器，获取或设置默认值
  // 获取分类列表
  @override
  void initState() {
    _titleTextEditingController =
        TextEditingController(text: widget.data?.title ?? "");
    _introduceTextEditingController =
        TextEditingController(text: widget.data?.introduce ?? "");

    _coverUrl = widget.data?.coverUrl ?? "";
    _materials = widget.data?.materials
            .map((e) => _RecipeMaterialsModel(
                TextEditingController(text: e.name),
                TextEditingController(text: e.dosage)))
            .toList() ??
        [
          _RecipeMaterialsModel(
              TextEditingController(text: ""), TextEditingController(text: ""))
        ];

    _steps = widget.data?.steps
            .map((e) => TextEditingController(text: e.desc))
            .toList() ??
        [TextEditingController(text: "")];
    _getRecipeClassifyList();

    _durationValueNotifier = ValueNotifier(
        Duration(hours: widget.data?.hr ?? 0, minutes: widget.data?.min ?? 0));
    super.initState();
  }

// 构建UI界面，包括AppBar、ListView和底部的发布按钮
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Add Recipe',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(233, 239, 249, 1), // 顶部导航栏背景色
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context), // 关闭当前页面
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
            children: [
              _buildCover(context), // 调用封面图片选择和预览的Widget
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: TextField(
                  controller: _titleTextEditingController,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    // 设置成灰色
                    color: Colors.black,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Recipe Title...', // 菜谱标题提示文本
                    // 加粗字体
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      // 设置成灰色
                      color: Color(0xFFBDBDBD),
                    ),
                    border:
                        InputBorder.none, // Removing any form of input border
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF001F4C),
                      ), // 设置下划线颜色
                    ),
                  ),
                ),
              ),

              _buildIntroduction(), // 调用introduction输入框的Widget
              const SizedBox(height: 15),
              _buildDurationPicker(context), // 调用时长输入框的Widget
              const SizedBox(height: 15),

              // _item2(context), // 调用分类选择器的Widget
              _buildCategorySelector(context),
              const SizedBox(height: 15),

              _buildMaterial(context),
              const SizedBox(height: 15),

              _buildStep(),
              const SizedBox(
                height: 60,
              )
            ],
          ),
        ],
      ),
      bottomNavigationBar: Container(
        width: double
            .infinity, // Ensures the container takes full width of the screen
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: const Color(0xFF001F4C),
              backgroundColor: const Color(0xFFCFE4FF),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: const Text(
              'Publish',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF001F4C),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              _submitData(context);
            },
          ),
        ),
      ),
    );
  }

// 构建时长输入框及其标签的widget
  Widget _buildDurationPicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            "Duration:", // 时长输入框上面的文字
            style: TextStyle(
              color: Color(0xFF0059D8), // 字体颜色
              fontWeight: FontWeight.bold, // 字体加粗
              fontSize: 16, // 字体大小
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            _showDurationPicker(context);
          },
          behavior: HitTestBehavior.opaque,
          child: ValueListenableBuilder(
            valueListenable: _durationValueNotifier,
            builder: (ctx, value, child) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    child: _buildDurationTextField(
                      context,
                      value.inHours,
                      'hr', // 将标签文本'hr'传入
                    ),
                  ),
                  const SizedBox(width: 10), // 添加间距
                  Expanded(
                    child: _buildDurationTextField(
                      context,
                      value.inMinutes % 60,
                      'min', // 将标签文本'min'传入
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

// 构建单个时长输入框，包括文本框和固定标签
  Widget _buildDurationTextField(BuildContext context, int data, String label) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF0059D8),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Center(
              child: Text(
                "$data",
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFFBDBDBD),
                ),
              ),
            ),
          ),
          Text(label), // 显示'hr'或'min'标签
        ],
      ),
    );
  }

// 构建introduction输入框的widget，包括标题和输入框
  _buildIntroduction() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            "Introduction:", // Label outside the container
            style: TextStyle(
              color: Color(0xFF0059D8), // Blue color for the label
              fontSize: 16, // Font size
              fontWeight: FontWeight.bold, // Bold font weight
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5), // Shadow color
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 3), // Shadow position
              ),
            ],
            borderRadius: BorderRadius.circular(12), // Rounded corners
            color: Colors.white, // Background color of the container
          ),
          child: TextField(
            controller: _introduceTextEditingController,
            decoration: InputDecoration(
              hintText: 'Story behind this dish...',
              // Placeholder text
              hintStyle: const TextStyle(
                // 设置成灰色
                color: Color(0xFFBDBDBD),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    12), // Rounded corners for the TextField
                borderSide: BorderSide.none, // No border line
              ),
              filled: true,
              fillColor: Colors.white, // Fill color inside the text field
            ),
            maxLines: 2, // Allows text to wrap up to three lines
          ),
        ),
      ],
    );
  }

  // 构建封面图片选择和预览的Widget
  _buildCover(BuildContext context) {
    if (_coverUrl.isNotEmpty) {
      return Stack(
        children: [
          SizedBox(
            height: 200,
            child: Image.network(
              _coverUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: OutlinedButton(
              onPressed: () => _showStyle(context),
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFF001F4C),
                padding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 8), // 减少padding
                textStyle: const TextStyle(fontSize: 10), // 调整字体大小
              ),
              child: const Text('Change Cover Image',
                  style: TextStyle(color: Colors.white, fontSize: 10)),
            ),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: OutlinedButton(
              onPressed: () => _showStyle(context),
              style: OutlinedButton.styleFrom(
                shape: const RoundedRectangleBorder(),
                // Removing the circle shape
                padding: const EdgeInsets.all(16),
                // Padding around the icon
                side: BorderSide.none, // Remove the outline border
              ),
              child: const Icon(
                Icons.add_a_photo_rounded, // Icon to add a photo
                color: Color(0xFF001F4C), // Setting the icon color
                size: 80, // Increasing the icon size
              ),
            ),
          ),
          const Text(
            'Add Cover Image', // Button text
            style: TextStyle(
              color: Color(0xFF001F4C),
              fontSize: 16,
              //加粗字体
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }
  }

  // 显示图片选择底部弹出菜单，并处理图片选择结果
  void _showStyle(BuildContext context) async {
    var res = await showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            color: Colors.white,
            height: 101,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(ImageSource.camera);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    height: 50,
                    child: const Text("take a picture"),
                  ),
                ),
                Container(
                  height: 1,
                  color: Colors.grey,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(ImageSource.gallery);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    height: 50,
                    child: const Text("photo album"),
                  ),
                ),
              ],
            ),
          );
        });

    if (res != null) {
      await _selectPic(res);
    }
  }

// 选择图片后上传到Firebase Storage，并获取下载URL
  Future<void> _selectPic(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(source: source);
      if (photo == null) {
        LoggerUtils.e("_selectPic photo = null");
        return;
      }
      final storageRef = FirebaseStorage.instance.ref();
      var nameRef = storageRef.child(photo.name);
      var namePathRef = storageRef.child("images/${photo.name}");

      assert(nameRef.name == namePathRef.name);
      assert(nameRef.fullPath != namePathRef.fullPath);
      LoggerUtils.i(photo.path);
      await nameRef.putFile(File(photo.path));
      _coverUrl = await nameRef.getDownloadURL();
      LoggerUtils.i(_coverUrl);
    } catch (e) {
      LoggerUtils.e(e);
    }
  }

  Widget _buildStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Text(
            "Recipe:", // 步骤列表的标题
            style: TextStyle(
              color: Color(0xFF0059D8), // 字体颜色蓝色
              fontWeight: FontWeight.bold, // 字体加粗
              fontSize: 16, // 字体大小
            ),
          ),
        ),
        //
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _steps.length,
          itemBuilder: (ctx, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: Stack(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.only(left: 40), // 给左侧文本留出空间
                    decoration: BoxDecoration(
                      color: Colors.white, // 设置容器背景色为白色
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5), // 设置阴影颜色
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(12), // 设置圆角
                    ),
                    child: TextField(
                      controller: _steps[index],
                      decoration: InputDecoration(
                        hintText: '  description',
                        // 提示文本
                        hintStyle: const TextStyle(
                          // 设置成灰色
                          color: Color(0xFFBDBDBD),
                        ),
                        labelText: 'Step ${index + 1}Description',
                        // 设置为输入框的标签
                        labelStyle: const TextStyle(color: Colors.transparent),
                        // 使标签文本透明
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        // 标签永不浮动
                        border: const OutlineInputBorder(
                          borderSide: BorderSide.none, // 无边框
                        ),
                        contentPadding: const EdgeInsets.only(
                          left: 30, // 增加左侧填充
                          top: 16,
                          bottom: 16,
                          right: 16,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Text(
                        'Step ${index + 1}', // 显示步骤编号
                        style: const TextStyle(
                          color: Color(0xFF0059D8), // 字体颜色蓝色
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15, top: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF001F4C), // 按钮背景颜色
                ),
                onPressed: () {
                  // TODO: 实现编辑逻辑
                  List<String> arguments = [];
                  for (var v in _steps) {
                    arguments.add(v.text);
                  }

                  Navigator.of(context).push(CupertinoPageRoute(builder: (ctx) {
                    return EditRecipePapge(
                      arguments: arguments,
                      callBack: (List<String> v) {
                        //.
                        _steps.clear();
                        for (var e in v) {
                          _steps.add(TextEditingController(text: e));
                        }
                        setState(() {});
                      },
                    );
                  }));
                  //
                },
                child: const Text('Edit'), // “Edit”按钮文本
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 15, top: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF001F4C), // 按钮背景颜色
                ),
                onPressed: () {
                  setState(() {
                    // 添加新的步骤控制器
                    _steps.add(TextEditingController());
                  });
                },
                child: const Text('Add more'), // “Add more”按钮文本
              ),
            ),
          ],
        ),
      ],
    );
  }

// 构建食材输入框的Widget
  Widget _buildMaterial(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 15,
          ), // 缩小标题与输入框的垂直距离
          child: Text(
            "Ingredients:", // 食材列表的标题
            style: TextStyle(
              color: Color(0xFF0059D8), // 字体颜色蓝色
              fontWeight: FontWeight.bold, // 字体加粗
              fontSize: 16, // 字体大小
            ),
          ),
        ),
        ListView.builder(
          // 从ListView.separated更改为ListView.builder
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (ctx, index) {
            var material = _materials[index];
            return Padding(
              padding: EdgeInsets.fromLTRB(
                  15, index == 0 ? 8 : 4, 15, 4), // 调整上下padding，减小两行之间的距离
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: material.left,
                      decoration: const InputDecoration(
                        hintText: 'e.g. milk',
                        // 左边输入框的提示词
                        hintStyle: TextStyle(
                          // 设置成灰色
                          color: Color(0xFFBDBDBD),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        // 用户点击输入时标签不浮动
                        enabledBorder: UnderlineInputBorder(
                          // 默认情况下的边框
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          // 获取焦点时的边框
                          borderSide:
                              BorderSide(color: Color(0xFF0059D8)), // 蓝色边框
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: material.right,
                      decoration: const InputDecoration(
                        hintText: 'quantity',
                        // 右边输入框的提示词
                        hintStyle: TextStyle(
                          // 设置成灰色
                          color: Color(0xFFBDBDBD),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        // 用户点击输入时标签不浮动
                        enabledBorder: UnderlineInputBorder(
                          // 默认情况下的边框
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          // 获取焦点时的边框
                          borderSide:
                              BorderSide(color: Color(0xFF0059D8)), // 蓝色边框
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
          itemCount: _materials.length,
        ),
        Row(
          // mainAxisAlignment: MainAxisAlignment.end, // 将按钮对齐到右侧
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // 使按钮分布在两侧

          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF001F4C), // 按钮背景颜色
                ),
                onPressed: () {
                  // Edit 操作的逻辑
                  List<Map<String, String>> arguments = [];
                  for (var val in _materials) {
                    arguments.add({"l": val.left.text, "r": val.right.text});
                  }
                  Navigator.of(context).push(CupertinoPageRoute(builder: (ctx) {
                    return EditIngredientsPage(
                      arguments: arguments,
                      callBack: (List<Map<String, String>> v) {
                        _materials.clear();
                        for (var e in v) {
                          _materials.add(_RecipeMaterialsModel(
                              TextEditingController(text: e["l"] ?? ""),
                              TextEditingController(text: e["r"] ?? "")));
                        }
                        setState(() {});
                      },
                    );
                  }));
                },
                child: const Text('Edit'), // “Edit”按钮文本
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF001F4C), // 按钮背景颜色
                ),
                onPressed: () {
                  setState(() {
                    _materials.add(_RecipeMaterialsModel(
                        TextEditingController(), TextEditingController()));
                  });
                },
                child: const Text('Add more'), // “Add more”按钮文本
              ),
            ),
          ],
        ),
      ],
    );
  }

// 构建分类选择器的Widget
  Widget _buildCategorySelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Text(
            "Category:", // 分类标签文本
            style: TextStyle(
              color: Color(0xFF0059D8), // 字体颜色蓝色
              fontWeight: FontWeight.bold, // 字体加粗
              fontSize: 16, // 字体大小
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              // children: _list.map((e) => _buildCategoryTab(context, e)).toList(),
              children:
                  _list.map((e) => _buildCategoryTab(context, e)).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // 构建单个分类Tab的Widget
  Widget _buildCategoryTab(BuildContext context, RecipeClassifyBean category) {
    bool isSelected = _classify == category; // 检查是否选中
    return GestureDetector(
      onTap: () {
        setState(() {
          _classify = category; // 更新选中的分类
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.all(4), // 为每个Tab添加边距
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0059D8)
              : Colors.transparent, // 根据是否选中设置背景颜色
          borderRadius: BorderRadius.circular(20), // 圆角边框
          border: Border.all(
            color: const Color(0xFF0059D8), // 蓝色边框
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              category.name,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : const Color(0xFF0059D8), // 根据是否选中设置文本颜色
                fontWeight: FontWeight.bold,
              ),
            ),
            // if (isSelected) // 如果选中，显示对勾图标
            //   Icon(Icons.check_circle, color: Colors.white, size: 24),
            if (isSelected) // 如果选中，在文本和对勾图标之间增加空间
              const SizedBox(width: 6), // 你可以根据需要调整宽度
            if (isSelected) // 如果选中，显示对勾图标
              const Icon(Icons.check_circle, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }

// 从数据库获取分类信息列表
  void _getRecipeClassifyList() async {
    try {
      var res = await FirebaseFirestore.instance
          .collection(DocumentsConfig.recipeClassify)
          .get();
      _list.clear();
      for (var doc in res.docs) {
        var recipeClassifyBean =
            RecipeClassifyBean.fromJson(doc.data(), doc.id);
        if (widget.data?.classifyCode == recipeClassifyBean.code) {
          _classify = recipeClassifyBean;
        }
        if (recipeClassifyBean.code != "0") {
          _list.add(recipeClassifyBean);
        }
      }
      setState(() {});
    } catch (e) {
      LoggerUtils.e(e);
    }
  }
}
