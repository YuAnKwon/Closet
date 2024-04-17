import 'package:flutter/material.dart';

class CategorySubCategoryWidgets extends StatefulWidget {
  final List<String> categories;
  final Map<String, List<String>> subCategories;
  final String? selectedCategory;
  final String? selectedSubCategory;
  final Function(String) onCategorySelected;
  final Function(String) onSubCategorySelected;

  CategorySubCategoryWidgets({
    required this.categories,
    required this.subCategories,
    required this.onCategorySelected,
    required this.onSubCategorySelected,
    this.selectedCategory,
    this.selectedSubCategory,
  });

  @override
  _CategorySubCategoryWidgetsState createState() =>
      _CategorySubCategoryWidgetsState();
}

class _CategorySubCategoryWidgetsState
    extends State<CategorySubCategoryWidgets> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: widget.categories
                .map((category) => GestureDetector(
              onTap: () {
                widget.onCategorySelected(category);
              },
              child: Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.selectedCategory == category
                      ? Colors.blue
                      : Colors.grey,
                ),
                child: Image.asset(
                  'assets/$category.png', // 각 카테고리에 맞는 이미지 경로로 변경
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
            ))
                .toList(),
          ),
        ),
        SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              if (widget.selectedCategory != null)
                ...widget.subCategories[widget.selectedCategory!]!
                    .map((subCategory) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      widget.onSubCategorySelected(subCategory);
                    },
                    child: Chip(
                      label: Text(
                        subCategory,
                        style: TextStyle(
                          color: widget.selectedSubCategory == subCategory
                              ? Colors.blue
                              : Colors.grey,
                        ),
                      ),
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      shape: StadiumBorder(
                        side: BorderSide(
                          color: widget.selectedSubCategory == subCategory
                              ? Colors.blue
                              : Colors.grey,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ))
                    .toList(),
            ],
          ),
        ),
      ],
    );
  }
}
