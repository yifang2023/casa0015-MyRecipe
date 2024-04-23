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

part 'model_recipe_add.dart';

// recipe add page
class RecipeAddPage extends StatefulWidget {
  final RecipeBean? data;

  const RecipeAddPage({super.key, this.data});

  @override
  State<RecipeAddPage> createState() => _RecipeAddPageState();
}

class _RecipeAddPageState extends State<RecipeAddPage> {
  final ImagePicker _picker = ImagePicker();

// text controllers for title and introduction
  late TextEditingController _titleTextEditingController;
  late TextEditingController _introduceTextEditingController;
  String _coverUrl = ""; // recipe cover image URL
  List<_RecipeMaterialsModel> _materials = []; // recipe materials
  RecipeClassifyBean? _classify; // recipe category
  List<TextEditingController> _steps = []; // recipe steps
  final List<RecipeClassifyBean> _list = []; // recipe category list

  late ValueNotifier<Duration> _durationValueNotifier;

// show duration picker
  Future<void> _showDurationPicker(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return SizedBox(
          height: MediaQuery.of(context).copyWith().size.height / 3,
          child: CupertinoTimerPicker(
            initialTimerDuration: _durationValueNotifier.value,
            mode: CupertinoTimerPickerMode.hm, // hour and minute
            onTimerDurationChanged: (Duration changedtimer) {
              _durationValueNotifier.value = changedtimer;
            },
          ),
        );
      },
    );
  }

  // check submit data if empty
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

// constrcut UI for recipe add page, including cover image, title, introduction, duration, category, materials, steps
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
        backgroundColor: const Color.fromRGBO(
            233, 239, 249, 1), // background color of the app bar
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context), // close the page
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
            children: [
              _buildCover(context), // cover image
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: TextField(
                  controller: _titleTextEditingController,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.black,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Recipe Title...', // title hint text
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
                      ),
                    ),
                  ),
                ),
              ),

              _buildIntroduction(), // introduction input box
              const SizedBox(height: 15),
              _buildDurationPicker(context), // duration picker
              const SizedBox(height: 15),
              _buildCategorySelector(context), // category selector
              const SizedBox(height: 15),

              _buildMaterial(context), // material input box
              const SizedBox(height: 15),

              _buildStep(), // step input box
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

// construct duration picker
  Widget _buildDurationPicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            "Duration:", // Label outside the container
            style: TextStyle(
              color: Color(0xFF0059D8),
              fontWeight: FontWeight.bold,
              fontSize: 16,
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
                      'hr',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildDurationTextField(
                      context,
                      value.inMinutes % 60,
                      'min',
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

// construct duration text field
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
          Text(label), // show label
        ],
      ),
    );
  }

// construct intruduction input box
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

  // construct cover image
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
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }
  }

  // Show the image selection bottom sheet and handle the image selection result
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

// Select an image from the camera or gallery, upload it to Firebase Storage, and get the download URL
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

// construct build step
  Widget _buildStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Text(
            "Recipe:",
            style: TextStyle(
              color: Color(0xFF0059D8),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
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
                    padding: const EdgeInsets.only(left: 40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _steps[index],
                      decoration: InputDecoration(
                        hintText: '  description',
                        hintStyle: const TextStyle(
                          color: Color(0xFFBDBDBD),
                        ),
                        labelText: 'Step ${index + 1}Description',
                        labelStyle: const TextStyle(color: Colors.transparent),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        border: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.only(
                          left: 30,
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
                        'Step ${index + 1}',
                        style: const TextStyle(
                          color: Color(0xFF0059D8),
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
                  backgroundColor: const Color(0xFF001F4C),
                ),
                onPressed: () {
                  List<String> arguments = [];
                  for (var v in _steps) {
                    arguments.add(v.text);
                  }

                  Navigator.of(context).push(CupertinoPageRoute(builder: (ctx) {
                    return EditRecipePapge(
                      arguments: arguments,
                      callBack: (List<String> v) {
                        _steps.clear();
                        for (var e in v) {
                          _steps.add(TextEditingController(text: e));
                        }
                        setState(() {});
                      },
                    );
                  }));
                },
                child: const Text('Edit'), // Edit button text
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 15, top: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF001F4C),
                ),
                onPressed: () {
                  setState(() {
                    // add new step controller
                    _steps.add(TextEditingController());
                  });
                },
                child: const Text('Add more'), // add more button text
              ),
            ),
          ],
        ),
      ],
    );
  }

// construct material input box
  Widget _buildMaterial(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 15,
          ),
          child: Text(
            "Ingredients:",
            style: TextStyle(
              color: Color(0xFF0059D8),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (ctx, index) {
            var material = _materials[index];
            return Padding(
              padding: EdgeInsets.fromLTRB(15, index == 0 ? 8 : 4, 15, 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: material.left,
                      decoration: const InputDecoration(
                        hintText: 'e.g. milk',
                        hintStyle: TextStyle(
                          color: Color(0xFFBDBDBD),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        // user click input label does not float
                        enabledBorder: UnderlineInputBorder(
                          // default border
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          // border when getting focus
                          borderSide: BorderSide(color: Color(0xFF0059D8)),
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
                        hintStyle: TextStyle(
                          color: Color(0xFFBDBDBD),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF0059D8)),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF001F4C),
                ),
                onPressed: () {
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
                child: const Text('Edit'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF001F4C),
                ),
                onPressed: () {
                  setState(() {
                    _materials.add(_RecipeMaterialsModel(
                        TextEditingController(), TextEditingController()));
                  });
                },
                child: const Text('Add more'),
              ),
            ),
          ],
        ),
      ],
    );
  }

// construct category selector
  Widget _buildCategorySelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Text(
            "Category:",
            style: TextStyle(
              color: Color(0xFF0059D8),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children:
                  _list.map((e) => _buildCategoryTab(context, e)).toList(),
            ),
          ),
        ),
      ],
    );
  }

// construct category tab
  Widget _buildCategoryTab(BuildContext context, RecipeClassifyBean category) {
    bool isSelected = _classify == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          _classify = category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0059D8) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF0059D8),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              category.name,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF0059D8),
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isSelected) const SizedBox(width: 6),
            if (isSelected) // if selected, show check icon
              const Icon(Icons.check_circle, color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }

// get recipe category list from firebase
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
