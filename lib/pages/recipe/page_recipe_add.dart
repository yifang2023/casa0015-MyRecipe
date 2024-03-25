import 'dart:io';

import 'package:MyRecipe/config/config_documents.dart';
import 'package:MyRecipe/model/bean_recipe.dart';
import 'package:MyRecipe/utils/utils_logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

part 'model_recipe_add.dart';

class RecipeAddPage extends StatefulWidget {
  final RecipeBean? data;

  const RecipeAddPage({super.key, this.data});

  @override
  State<RecipeAddPage> createState() => _RecipeAddPageState();
}

class _RecipeAddPageState extends State<RecipeAddPage> {
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _titleTextEditingController;
  late TextEditingController _introduceTextEditingController;
  late TextEditingController _durationTextEditingController;
  String _coverUrl = "";
  List<_RecipeMaterialsModel> _materials = [];
  RecipeClassifyBean? _classify;
  List<TextEditingController> _steps = [];
  final List<RecipeClassifyBean> _list = [];

  void _submitData(BuildContext context) {
    if (_coverUrl.isEmpty) {
      return;
    }
    var title = _titleTextEditingController.text;
    if (title.isEmpty) {
      return;
    }
    var introduce = _introduceTextEditingController.text;
    if (introduce.isEmpty) {
      return;
    }
    var duration = _durationTextEditingController.text;
    if (duration.isEmpty) {
      return;
    }
    if (_classify == null) {
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
      duration,
      materials,
      steps,
      DateTime.now().millisecondsSinceEpoch,
      DocumentsConfig.userId ?? "",
    );
    if (tempData == null) {
      FirebaseFirestore.instance
          .collection(DocumentsConfig.recipe)
          .add(submitData.toJson())
          .then((value) {
        LoggerUtils.i("add success");
        Navigator.maybePop(context);
      }).catchError((e) {
        LoggerUtils.e(e);
      });
    } else {
      FirebaseFirestore.instance
          .collection(DocumentsConfig.recipe)
          .doc(tempData)
          .update(submitData.toJson())
          .then((value) {
        LoggerUtils.e("update success");
        Navigator.maybePop(context);
      }).catchError((e) {
        LoggerUtils.e(e);
      });
    }
  }

  @override
  void initState() {
    _titleTextEditingController =
        TextEditingController(text: widget.data?.title ?? "");
    _introduceTextEditingController =
        TextEditingController(text: widget.data?.introduce ?? "");
    _durationTextEditingController =
        TextEditingController(text: widget.data?.duration ?? "");
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Recipe',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(233, 239, 249, 1),
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
              _buildCover(context),
              TextField(
                controller: _titleTextEditingController,
                decoration: InputDecoration(
                  hintText: 'Recipe Title',
                  // 加粗字体
                  hintStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xFFE0E0E0)), // 设置下划线颜色为浅灰色
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).primaryColor), // 聚焦时保持主题颜色
                  ),
                ),
              ),
              TextField(
                controller: _introduceTextEditingController,
                decoration: const InputDecoration(
                  border: InputBorder.none, // 移除边界装饰
                  hintText: 'Story behind this dish...',
                ),
                maxLines: 3,
              ),
              _item2(context),
              TextField(
                controller: _durationTextEditingController,
                decoration: const InputDecoration(
                    labelText: 'Duration (e.g., 1 hr 20 min)'),
              ),
              ..._buildMaterial(),
              ..._buildStep(),
              const SizedBox(
                height: 60,
              )
            ],
          ),
          Positioned(
            left: 20,
            bottom: 20,
            right: 20,
            child: ElevatedButton(
              child: const Text('Publish Recipe'),
              onPressed: () {
                _submitData(context);
              },
            ),
          ),
        ],
      ),
    );
  }

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
                backgroundColor: Colors.black45,
              ),
              child: const Text('Change Cover Image',
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      );
    } else {
      return OutlinedButton(
        onPressed: () => _showStyle(context),
        child: const Text('Add Cover Image'),
      );
    }
  }

  _item(String leftText, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey)),
      ),
      child: Row(
        children: [
          Text(leftText),
          Expanded(
            child: TextField(
              controller: controller,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
                hintText: "请输入",
              ),
            ),
          )
        ],
      ),
    );
  }

  _item2(
    BuildContext context,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _showTabs(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey)),
        ),
        child: Row(
          children: [
            const Text("Category"),
            Expanded(
              child: Text(
                _classify == null ? "" : "${_classify?.name}",
                textAlign: TextAlign.end,
              ),
            ),
            const Icon(Icons.keyboard_arrow_right)
          ],
        ),
      ),
    );
  }

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

  _buildMaterial() {
    return [
      ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (ctx, index) {
          var material = _materials[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: material.left,
                    decoration: const InputDecoration(labelText: 'Ingredient'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: material.right,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                  ),
                )
              ],
            ),
          );
        },
        separatorBuilder: (ctx, index) {
          return Container(
            height: 1,
            color: Colors.grey,
          );
        },
        itemCount: _materials.length,
      ),
      ElevatedButton(
        onPressed: () {
          setState(() {
            _materials.add(_RecipeMaterialsModel(
                TextEditingController(), TextEditingController()));
          });
        },
        child: const Text('Add more ingredients'),
      ),
    ];
  }

  _buildStep() {
    return [
      ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (ctx, index) {
          var data = _steps[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              controller: data,
              decoration:
                  InputDecoration(labelText: 'Step ${index + 1} Description'),
            ),
          );
        },
        separatorBuilder: (ctx, index) {
          return Container(
            height: 1,
            color: Colors.grey,
          );
        },
        itemCount: _steps.length,
      ),
      ElevatedButton(
        onPressed: () {
          setState(
            () {
              _steps.add(TextEditingController());
            },
          );
        },
        child: const Text('Add more steps'),
      ),
    ];
  }

  void _showTabs(BuildContext context) async {
    if (_list.isEmpty) {
      return;
    }
    var res = await showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            color: Colors.white,
            height: 500,
            child: ListView.separated(
                itemBuilder: (ctx, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(_list[index]);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        _list[index].name,
                        style: TextStyle(
                          color: _classify?.code == _list[index].code
                              ? Colors.red
                              : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (ctx, index) {
                  return Container(
                    height: 1,
                    color: Colors.grey,
                  );
                },
                itemCount: _list.length),
          );
        });
    if (res != null) {
      setState(() {
        _classify = res;
      });
    }
  }

  void _getRecipeClassifyList() async {
    try {
      var res = await FirebaseFirestore.instance
          .collection(DocumentsConfig.recipeClassify)
          .get();
      LoggerUtils.i(res.docs);
      _list.clear();
      for (var doc in res.docs) {
        var recipeClassifyBean =
            RecipeClassifyBean.fromJson(doc.data(), doc.id);
        if (widget.data?.classifyCode == recipeClassifyBean.code) {
          _classify = recipeClassifyBean;
        }
        _list.add(recipeClassifyBean);
      }
      setState(() {});
    } catch (e) {
      LoggerUtils.e(e);
    }
  }
}
