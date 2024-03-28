class RecipeBean {
  late String title;
  late String id;
  late String coverUrl;
  late String introduce;
  late String duration;
  late String classifyName;
  late String classifyCode;
  late String userId;
  late int time;
  late List<RecipeMaterialsBean> materials;
  late List<RecipeStepBean> steps;

  RecipeBean(
      this.id,
      this.title,
      this.coverUrl,
      this.introduce,
      this.classifyName,
      this.classifyCode,
      this.duration,
      this.materials,
      this.steps,
      this.time,
      this.userId);

  RecipeBean.fromJson(Map<String, dynamic>? json, this.id) {
    title = json?['title'] ?? "";
    coverUrl = json?['coverUrl'] ?? "";
    introduce = json?['introduce'] ?? "";
    classifyName = json?['clas sifyName'] ?? "";
    classifyCode = json?['classifyCode'] ?? "";
    duration = json?['duration'] ?? "";

    materials = <RecipeMaterialsBean>[];
    if (json?['materials'] != null) {
      json?['materials'].forEach((v) {
        materials.add(RecipeMaterialsBean.fromJson(v));
      });
    }

    steps = <RecipeStepBean>[];
    if (json?['steps'] != null) {
      json?['steps'].forEach((v) {
        steps.add(RecipeStepBean.fromJson(v));
      });
    }

    time = json?['time'] ?? 0;
    userId = json?['userId'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['coverUrl'] = coverUrl;
    data['introduce'] = introduce;
    data['classifyCode'] = classifyCode;
    data['classifyName'] = classifyName;
    data['duration'] = duration;
    data['time'] = time;
    data['userId'] = userId;
    data['materials'] = materials.map((e) => e.toJson()).toList();
    data['steps'] = steps.map((e) => e.toJson()).toList();
    return data;
  }

  @override
  String toString() {
    return 'RecipeBean{title: $title, id: $id, coverUrl: $coverUrl, introduce: $introduce, duration: $duration, classifyName: $classifyName, classifyCode: $classifyCode, userId: $userId, time: $time, materials: $materials, steps: $steps}';
  }
}

class RecipeMaterialsBean {
  late String name;
  late String dosage;

  RecipeMaterialsBean(this.name, this.dosage);

  RecipeMaterialsBean.fromJson(Map<String, dynamic>? json) {
    name = json?["name"] ?? "";
    dosage = json?["dosage"] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['dosage'] = dosage;
    return data;
  }
}

class RecipeClassifyBean {
  late String name;
  late String code;
  late String id;

  RecipeClassifyBean(this.id, this.name, this.code);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['code'] = code;
    data['id'] = id;
    return data;
  }

  RecipeClassifyBean.fromJson(Map<String, dynamic>? json, this.id) {
    name = json?['name'] ?? "";
    code = json?['code'] ?? "";
  }
}

class RecipeStepBean {
  late String desc;

  RecipeStepBean(this.desc);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['desc'] = desc;
    return data;
  }

  RecipeStepBean.fromJson(Map<String, dynamic>? json) {
    desc = json?["desc"] ?? "";
  }
}
