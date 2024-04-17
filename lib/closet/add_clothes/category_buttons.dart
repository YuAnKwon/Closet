import 'package:flutter/material.dart';

class CategorySubCategoryWidgets extends StatelessWidget {
  final List<String> categories;
  final Map<String, List<String>> subCategories;
  final Function(String) onCategorySelected;
  final Function(String) onSubCategorySelected;
  final String? selectedCategory;
  final String? selectedSubCategory;

  const CategorySubCategoryWidgets({
    required this.categories,
    required this.subCategories,
    required this.onCategorySelected,
    required this.onSubCategorySelected,
    required this.selectedCategory,
    required this.selectedSubCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCategoryButtons(),
        SizedBox(height: 20),
        _buildSubCategories(),
      ],
    );
  }

  Widget _buildCategoryButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: categories
          .map((category) => ElevatedButton(
        onPressed: () {
          onCategorySelected(category);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedCategory == category
              ? Color(0xDAD9FF)
              : null,
        ),
        child: Text(category),
      ))
          .toList(),
    );
  }

  Widget _buildSubCategories() {
    if (selectedCategory == null) {
      return SizedBox.shrink();
    }
    final subCategoryList = subCategories[selectedCategory!] ?? [];
    return Wrap(
      spacing: 10,
      children: subCategoryList
          .map((subCategory) => ElevatedButton(
        onPressed: () {
          onSubCategorySelected(subCategory);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedSubCategory == subCategory
              ? Color(0xDAD9FF)
              : null,
        ),
        child: Text(subCategory),
      ))
          .toList(),
    );
  }
}
