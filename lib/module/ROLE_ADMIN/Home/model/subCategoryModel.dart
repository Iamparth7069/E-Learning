class SubCategoryModel {
  int categoryId;
  String name;
  int subCategoryId;

  SubCategoryModel({required this.categoryId, required this.name,required this.subCategoryId});

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      subCategoryId: json['subCategoryId'] as int,
      categoryId: json['categoryId'] as int,
      name: json['name'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subCategoryId' : subCategoryId,
      'categoryId': categoryId,
      'name': name,
    };
  }
}
