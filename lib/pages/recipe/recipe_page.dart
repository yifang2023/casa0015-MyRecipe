import 'package:MyRecipe/config/config_documents.dart';
import 'package:MyRecipe/model/bean_recipe.dart';
import 'package:MyRecipe/pages/recipe/page_recipe_add.dart';
import 'package:MyRecipe/pages/recipe/recipe_details_page.dart';
import 'package:MyRecipe/utils/utils_logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

part 'recipe_card.dart';

class RecipePage extends StatefulWidget {
  const RecipePage({super.key});

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final List<RecipeClassifyBean> _tabs = [];
  final List<RecipeBean> _dataList = [];
  final List<RecipeBean> _allDataList = [];
  final Map<String, List<RecipeBean>> _dataMap = {};
  int _selectedIndex = 0;

  String _searchKey = "";

  bool _isloading = true;

  @override
  void initState() {
    _getRecipeClassifyList();
    super.initState();
  }

  void _getRecipeClassifyList() async {
    try {
      var res = await FirebaseFirestore.instance
          .collection(DocumentsConfig.recipeClassify)
          .get();

      _tabs.clear();
      for (var doc in res.docs) {
        var recipeClassifyBean =
            RecipeClassifyBean.fromJson(doc.data(), doc.id);
        LoggerUtils.i(recipeClassifyBean);
        _tabs.add(recipeClassifyBean);
      }
      await _refreshList();
    } catch (e) {
      LoggerUtils.e(e);
    }
  }

  Future<void> _refreshList() async {
    try {
      var collection =
          FirebaseFirestore.instance.collection(DocumentsConfig.recipe);
      var res = await collection.orderBy("time", descending: true).get();
      _dataMap.clear();
      _allDataList.clear();
      for (var doc in res.docs) {
        var recipeBean = RecipeBean.fromJson(doc.data(), doc.id);
        _allDataList.add(recipeBean);
        var dataMap = _dataMap[recipeBean.classifyCode];
        if (dataMap == null) {
          var temp = <RecipeBean>[];
          temp.add(recipeBean);
          _dataMap[recipeBean.classifyCode] = temp;
        } else {
          dataMap.add(recipeBean);
          _dataMap[recipeBean.classifyCode] = dataMap;
        }
      }
      LoggerUtils.i(_dataList);
      _changeData();
    } catch (e) {
      LoggerUtils.e(e);
    } finally {
      _isloading = false;
    }
  }

  _changeData() {
    _dataList.clear();
    var elementAtOrNull = _tabs.elementAtOrNull(_selectedIndex);
    if (elementAtOrNull != null) {
      var dataMap = _dataMap[elementAtOrNull.code];
      if (dataMap != null) {
        _dataList.addAll(dataMap);
      } else {
        if (elementAtOrNull.code == "0") {
          _dataList.addAll(_allDataList);
        }
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        _buildHeader(context),
        _buildSearch(context),
        _buildCategory(context),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await _refreshList();
            },
            child: _buildContent(context),
          ),
        )
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFE9EFF9),
      elevation: 0,
      // Remove shadow if needed
      centerTitle: true,
      // Center the title
      title: const Text(
        'My Recipe',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF001F4C),
        ),
      ),
      actions: <Widget>[
        IconButton(
          onPressed: () {
            _add(context);
          },
          icon: const Icon(Icons.add_box_rounded),
          color: const Color(0xFF001F4C),
        ),
      ],
    );
  }

  ///
  /// 添加数据
  /// https://firebase.google.com/docs/firestore/quickstart?hl=zh-cn#add_data
  ///
  void _add(BuildContext context) async {
    await Navigator.of(context).push(CupertinoPageRoute(builder: (ctx) {
      return const RecipeAddPage();
    }));
  }

  Widget _buildSearch(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 25, 20, 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4FB),
        // Set the background color of the search box
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.search,
            color: Colors.grey[500],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                color: Colors.black,
              ),
              onSubmitted: (content) {
                _search(context, content);
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                isDense: true,
                border: InputBorder.none,
                hintText: 'Search for recipes',
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _search(BuildContext context, String content) async {
    _searchKey = content;
    List<RecipeBean> temp = [];
    _dataList.clear();
    var dataMap = _dataMap[_tabs.elementAtOrNull(_selectedIndex)];
    if (dataMap != null) {
      if (_searchKey.isNotEmpty) {
        for (var value in dataMap) {
          if (value.title.contains(_searchKey)) {
            temp.add(value);
          } else {
            // ingredients
            for (var item in value.materials) {
              if (item.name.contains(_searchKey)) {
                temp.add(value);
                break;
              }
            }
          }
        }
      } else {
        temp.addAll(dataMap);
      }
    }
    _dataList.addAll(temp);

    setState(() {});
  }

  Widget _buildCategory(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: SizedBox(
        height: 25,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _tabs.length,
          itemBuilder: (context, index) => _buildCategoryItem(index),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(int index) {
    bool isSelected = _selectedIndex == index; // Check if the tab is selected
    return GestureDetector(
      onTap: () {
        _changeTab(index);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        margin: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF001F4C) : const Color(0xFFF2F4FB),
          // Change background color based on selection
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _tabs[index].name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected
                ? Colors.white
                : Colors.black, // Change text color based on selection
          ),
        ),
      ),
    );
  }

  void _changeTab(int index) async {
    if (index == _selectedIndex) {
      return;
    }
    _selectedIndex = index;

    _changeData();
  }

  Widget _buildContent(BuildContext context) {
    if (_isloading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (_dataList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'asset/recipe.png', // Replace with your asset image path
              width: 200, // Set the image width to fit your design
              height: 200, // Set the image height to fit your design
            ),
            const SizedBox(height: 20),
            // Provide some spacing between image and text
            const Text(
              'No recipes yet. Start creating your recipe now!',
              textAlign: TextAlign.center,
              style: TextStyle(
                //设置字体颜色为灰色
                color: Colors.grey,
                fontSize: 16, // Adjust the font size as needed
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            // Provide some spacing between text and button
            ElevatedButton(
              onPressed: () {
                // Add your onPressed function here
                _add(context);
              },
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(
                      0xFF001F4C) // Set the text color for the button
                  ),
              child: const Text('Add new recipe'),
            ),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: _dataList.length,
      itemBuilder: (ctx, index) {
        return GestureDetector(
          onTap: () => _jumpDetail(context, _dataList[index]),
          behavior: HitTestBehavior.opaque,
          child: RecipeCard(
            data: _dataList[index],
          ),
        );
      },
    );
  }

  void _jumpDetail(BuildContext context, RecipeBean data) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (ctx) {
          return RecipeDetailPage(
            data: data,
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
