class CategoryModel {
  int categoryId;
  String name;

  CategoryModel({required this.categoryId, required this.name});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryId: json['categoryId'] as int,
      name: json['name'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'name': name,
    };
  }
}
