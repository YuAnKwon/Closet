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
        SizedBox(height: 20), // Add some spacing at the top
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.categories
              .map((category) => GestureDetector(
            onTap: () {
              widget.onCategorySelected(category);
            },
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: widget.selectedCategory == category
                        ? Colors.blue.withOpacity(0.8)
                        : Colors.grey.withOpacity(0.5),
                  ),
                  child: Image.asset(
                    'assets/$category.png', // Update with your image path
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 4), // Add spacing between the image and text
                Text(
                  category,
                  style: TextStyle(
                    color: widget.selectedCategory == category
                        ? Colors.blue
                        : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ))
              .toList(),
        ),
        SizedBox(height: 16),
        Center( // Center the subcategories horizontally
          child: SingleChildScrollView(
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
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        backgroundColor: widget.selectedSubCategory == subCategory
                            ? Colors.blue
                            : Colors.grey.withOpacity(0.3),
                        elevation: 0,
                        shape: StadiumBorder(
                          side: BorderSide.none,
                        ),
                      ),
                    ),
                  ))
                      .toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

