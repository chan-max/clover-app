import 'package:flutter/material.dart';

class Category {
  final String label;
  final Color color;
  Category({required this.label, required this.color});
}

class CategoryTabs extends StatelessWidget {
  final List<Category> categories;
  final  onRefresh;
  final void Function(String categoryName) onCategoryClick;

  CategoryTabs({required this.categories, required this.onRefresh, required this.onCategoryClick});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              SizedBox(width: 4),
              ...categories.map((category) {
             return Padding(
  padding: EdgeInsets.symmetric(horizontal: 4),
  child: Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        onRefresh(category.label);
        print('点击了分类: ${category.label}');
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: category.color,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          category.label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  ),
);

              }).toList(),
            ],
          ),
        ),
        // Padding(
        //   padding: EdgeInsets.symmetric(horizontal: 4),
        //   child: GestureDetector(
        //     onTap: onRefresh,
        //     child: Container(
        //       padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        //       decoration: BoxDecoration(
        //         color: Colors.grey[800],
        //         borderRadius: BorderRadius.circular(20),
        //       ),
        //       alignment: Alignment.center,
        //       child: Icon(
        //         Icons.refresh,
        //         color: Colors.white,
        //         size: 16,
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}