import 'package:flutter/material.dart';

class EditRecipePapge extends StatefulWidget {
  final List<String> arguments;
  final Function(List<String>) callBack;
  const EditRecipePapge(
      {Key? key, required this.arguments, required this.callBack})
      : super(key: key);

  @override
  State<EditRecipePapge> createState() => _EditRecipePapgeState();
}

class _EditRecipePapgeState extends State<EditRecipePapge> {
  List<String> data = [];
  @override
  void initState() {
    super.initState();
    data = widget.arguments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Change Recipe',
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
                  color: Color(0xFF001F4C),
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
          return _item(index, data[index], onTap: () {
            data.removeAt(index);
            setState(() {});
          });
        },
      ),
    );
  }

  Widget _item(int index, String v, {void Function()? onTap}) {
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
                    "step ${index + 1}",
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    v,
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
