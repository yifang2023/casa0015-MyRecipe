// import 'package:flutter/material.dart';

// class AddRecipePage extends StatefulWidget {
//   @override
//   _AddRecipePageState createState() => _AddRecipePageState();
// }

// class _AddRecipePageState extends State<AddRecipePage> {
//   final _formKey = GlobalKey<FormState>();
//   String _title = '';
//   String _story = '';
//   String _category = 'Main Course'; // 默认选择
//   String _duration = '';
//   List<String> _categories = ['Starter', 'Main Course', 'Dessert', 'Snack'];
//   List<Map<String, String>> _ingredients = [];
//   List<String> _steps = [];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Add Recipe')),
//       body: Form(
//         key: _formKey,
//         child: ListView(
//           padding: EdgeInsets.all(20),
//           children: <Widget>[
//             TextFormField(
//               decoration: InputDecoration(labelText: 'Recipe Title'),
//               onSaved: (value) => _title = value!,
//             ),
//             TextFormField(
//               decoration: InputDecoration(labelText: 'Story behind this dish'),
//               onSaved: (value) => _story = value!,
//               maxLines: 3,
//             ),
//             DropdownButtonFormField(
//               value: _category,
//               decoration: InputDecoration(labelText: 'Category'),
//               items: _categories.map((String category) {
//                 return DropdownMenuItem(
//                   value: category,
//                   child: Text(category),
//                 );
//               }).toList(),
//               onChanged: (String? newValue) {
//                 setState(() {
//                   _category = newValue!;
//                 });
//               },
//             ),
//             TextFormField(
//               decoration: InputDecoration(labelText: 'Duration (e.g., 1 hr 20 min)'),
//               onSaved: (value) => _duration = value!,
//             ),
//             ..._ingredients.map((ingredient) {
//               return Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: TextFormField(
//                       decoration: InputDecoration(labelText: 'Ingredient'),
//                       initialValue: ingredient['name'],
//                       onChanged: (value) => ingredient['name'] = value,
//                     ),
//                   ),
//                   SizedBox(width: 10),
//                   Expanded(
//                     child: TextFormField(
//                       decoration: InputDecoration(labelText: 'Quantity'),
//                       initialValue: ingredient['quantity'],
//                       onChanged: (value) => ingredient['quantity'] = value,
//                     ),
//                   ),
//                 ],
//               );
//             }).toList(),
//             ElevatedButton(
//               child: Text('Add more ingredients'),
//               onPressed: () => setState(() => _ingredients.add({'name': '', 'quantity': ''})),
//             ),
//             ..._steps.asMap().entries.map((entry) {
//               int index = entry.key;
//               String step = entry.value;
//               return ListTile(
//                 title: TextFormField(
//                   decoration: InputDecoration(labelText: 'Step ${index + 1} Description'),
//                   initialValue: step,
//                   onChanged: (value) => _steps[index] = value,
//                 ),
//               );
//             }).toList(),
//             ElevatedButton(
//               child: Text('Add more steps'),
//               onPressed: () => setState(() => _steps.add('')),
//             ),
//             ElevatedButton(
//               child: Text('Publish Recipe'),
//               onPressed: () {
//                 _formKey.currentState!.save();
//                 // 这里可以将数据保存到数据库或云端
//                 print('Recipe Published: $_title, $_category, $_duration');
//                 Navigator.pop(context);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // 引入图片选择库，确保已在pubspec.yaml中添加依赖
import 'dart:io'; // 用于处理文件

class AddRecipePage extends StatefulWidget {
  @override
  _AddRecipePageState createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _story = '';
  String _category = 'Main Course'; // 默认选择
  String _duration = '';
  List<String> _categories = ['Starter', 'Main Course', 'Dessert', 'Snack'];
  List<Map<String, String>> _ingredients = [
    {'name': '', 'quantity': ''}
  ];
  List<String> _steps = [''];
  XFile? _image;

  final ImagePicker _picker = ImagePicker();

  // 异步函数用于从图库选择图片
  Future<void> _pickImage() async {
    final XFile? selected =
        await _picker.pickImage(source: ImageSource.gallery);
    if (selected != null) {
      setState(() {
        _image = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Recipe'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context), // 关闭当前页面
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(20),
          children: <Widget>[
            if (_image != null)
              Stack(
                children: [
                  Image.file(
                    File(_image!.path),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: OutlinedButton(
                      onPressed: _pickImage,
                      child: Text('Change Cover Image',
                          style: TextStyle(color: Colors.white)),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.black45,
                      ),
                    ),
                  ),
                ],
              ),
            if (_image == null)
              OutlinedButton(
                onPressed: _pickImage,
                child: Text('Add Cover Image'),
              ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Recipe Title'),
              onSaved: (value) => _title = value ?? '',
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Story behind this dish'),
              onSaved: (value) => _story = value ?? '',
              maxLines: 3,
            ),
            DropdownButtonFormField(
              value: _category,
              decoration: InputDecoration(labelText: 'Category'),
              items: _categories.map((String category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _category = newValue;
                  });
                }
              },
            ),
            TextFormField(
              decoration:
                  InputDecoration(labelText: 'Duration (e.g., 1 hr 20 min)'),
              onSaved: (value) => _duration = value ?? '',
            ),
            ..._ingredients.map((ingredient) {
              int index = _ingredients.indexOf(ingredient);
              return Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Ingredient'),
                      initialValue: ingredient['name'],
                      onChanged: (value) => _ingredients[index]['name'] = value,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Quantity'),
                      initialValue: ingredient['quantity'],
                      onChanged: (value) =>
                          _ingredients[index]['quantity'] = value,
                    ),
                  ),
                ],
              );
            }).toList(),
            ElevatedButton(
              child: Text('Add more ingredients'),
              onPressed: () => setState(
                  () => _ingredients.add({'name': '', 'quantity': ''})),
            ),
            ..._steps.map((step) {
              int index = _steps.indexOf(step);
              return TextFormField(
                decoration:
                    InputDecoration(labelText: 'Step ${index + 1} Description'),
                initialValue: step,
                onChanged: (value) => _steps[index] = value,
              );
            }).toList(),
            ElevatedButton(
              child: Text('Add more steps'),
              onPressed: () => setState(() => _steps.add('')),
            ),
            ElevatedButton(
              child: Text('Publish Recipe'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  // 这里可以将数据保存到数据库或云端
                  print('Recipe Published: $_title, $_category, $_duration');
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AddRecipePage(),
  ));
}
