import 'package:MyRecipe/config/config_documents.dart';
import 'package:MyRecipe/model/bean_recipe.dart';
import 'package:MyRecipe/pages/recipe/page_recipe_add.dart';
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
  int _selectedIndex = 0;

  String _searchKey = "";

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
      setState(() {});
    } catch (e) {
      LoggerUtils.e(e);
    }
  }

  Future<void> _refreshList() async {
    try {
      var collection =
          FirebaseFirestore.instance.collection(DocumentsConfig.recipe);
      var elementAtOrNull = _tabs.elementAtOrNull(_selectedIndex);
      if (elementAtOrNull != null) {
        collection.where("classifyCode", isEqualTo: elementAtOrNull.code);
      }
      var res = await collection.orderBy("time", descending: true).get();
      _dataList.clear();
      for (var doc in res.docs) {
        var recipeClassifyBean = RecipeBean.fromJson(doc.data(), doc.id);
        if (_searchKey.isNotEmpty) {
          if (recipeClassifyBean.title.contains(_searchKey)) {
            _dataList.add(recipeClassifyBean);
          }
        } else {
          _dataList.add(recipeClassifyBean);
        }
      }
      LoggerUtils.i(_dataList);
      setState(() {});
    } catch (e) {
      LoggerUtils.e(e);
    }
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
    return SafeArea(
      child: SizedBox(
        height: 44,
        child: Stack(
          children: [
            const Center(
              child: Text(
                'Recipe Page',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () {
                  _add(context);
                },
                icon: const Icon(Icons.add),
              ),
            )
          ],
        ),
      ),
    );
  }

  ///
  /// 添加数据
  /// https://firebase.google.com/docs/firestore/quickstart?hl=zh-cn#add_data
  ///
  void _add(BuildContext context) async {
    Navigator.of(context).push(CupertinoPageRoute(builder: (ctx) {
      return const RecipeAddPage();
    }));
  }

  Widget _buildSearch(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.search,
            color: Colors.blue[500],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                color: Colors.blue[500],
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
                  color: Colors.blue[500],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _search(BuildContext context, String content) async {
    setState(() {
      _searchKey = content;
    });

    await _refreshList();
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
          color: _selectedIndex == index ? Colors.blue[50] : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _tabs[index].name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue[500],
          ),
        ),
      ),
    );
  }

  void _changeTab(int index) async {
    if (index == _selectedIndex) {
      return;
    }
    setState(() {
      _selectedIndex = index;
    });

    await _refreshList();
  }

  Widget _buildContent(BuildContext context) {
    if (_dataList.isEmpty) {
      return const Center(
        child: Text("no data"),
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
          return RecipeAddPage(
            data: data,
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
