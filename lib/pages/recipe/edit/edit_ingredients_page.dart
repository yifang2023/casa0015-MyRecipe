import 'package:flutter/material.dart';

class EditIngredientsPage extends StatefulWidget {
  final List<Map<String, String>> arguments;
  final Function(List<Map<String, String>>) callBack;
  const EditIngredientsPage(
      {Key? key, required this.arguments, required this.callBack})
      : super(key: key);

  @override
  State<EditIngredientsPage> createState() => _EditIngredientsPageState();
}

class _EditIngredientsPageState extends State<EditIngredientsPage> {
  List<Map<String, String>> data = [];
  @override
  void initState() {
    super.initState();
    data = widget.arguments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Change Ingredients',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(233, 239, 249, 1), // 顶部导航栏背景色
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            size: 36,
          ),
          onPressed: () => Navigator.pop(context), // 关闭当前页面
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: InkWell(
              onTap: () {
                widget.callBack(data);
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade500,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "done",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          )
        ],
      ),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (BuildContext context, int index) {
          return _item(data[index], onTap: () {
            data.removeAt(index);
            setState(() {});
          });
        },
      ),
    );
  }

  Widget _item(Map<String, String> value, {void Function()? onTap}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 5),
      child: Row(
        children: [
          InkWell(
            onTap: onTap,
            child: const Icon(
              Icons.cancel,
              color: Colors.blue,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value["l"] ?? "-",
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 1,
                    color: Colors.grey.shade300,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
