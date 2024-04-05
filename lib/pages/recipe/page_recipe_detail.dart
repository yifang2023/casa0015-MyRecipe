import 'package:MyRecipe/model/bean_recipe.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RecipeDetailPage extends StatefulWidget {
  final RecipeBean data;

  const RecipeDetailPage({super.key, required this.data});

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8EFF9),
        actions: [
          IconButton(
              onPressed: () {
                _showBottom(context);
              },
              icon: const Icon(Icons.list))
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(15),
        children: [
          Text(widget.data.title),
          Text("Introduction:"),
          Container(
            child: Text(widget.data.introduce),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Color(0xFFE8EFF9),
            ),
          ),
          Text("Duration:"),
          Row(
            children: [
              Icon(Icons.lock_clock),
              Text(widget.data.getDuration()),
            ],
          ),
          Text("Ingredients:"),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (ctx, index) {
              var material = widget.data.materials[index];
              return Container(
                height: 36,
                decoration: BoxDecoration(
                    color: const Color(0xFFE8EFF9),
                    borderRadius: BorderRadius.circular(18)),
                child: Row(
                  children: [
                    Expanded(child: Text(material.name)),
                    Text(material.dosage)
                  ],
                ),
              );
            },
            separatorBuilder: (ctx, index) {
              return const SizedBox(
                height: 10,
              );
            },
            itemCount: widget.data.materials.length,
          ),
          Text("Recipe:"),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (ctx, index) {
              var material = widget.data.steps[index];
              return Container(
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EFF9),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Text("step1 "),
                    Expanded(child: Text(material.desc)),
                  ],
                ),
              );
            },
            separatorBuilder: (ctx, index) {
              return const SizedBox(
                height: 10,
              );
            },
            itemCount: widget.data.steps.length,
          )
        ],
      ),
    );
  }

  void _showBottom(BuildContext context) async {
    await showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return Container(
            height: 160,
            color: Colors.white,
            child: Column(
              children: [
                const SizedBox(height: 10,),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [Icon(Icons.edit), Text("编辑")],
                            ),
                          )
                        ],
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [Icon(Icons.delete), Text("dlete")],
                            ),
                          )
                        ],
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
                GestureDetector(
                  onTap: () {},
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EFF9),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    alignment: Alignment.center,
                    child: Text("cancel"),
                  ),
                ),
                const SizedBox(height: 10,),
              ],
            ),
          );
        });
  }
}
