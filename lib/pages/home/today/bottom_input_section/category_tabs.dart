import 'package:flutter/material.dart';

class Category {
  final String label;
  final Color color;
  Category({required this.label, required this.color});
}

class CategoryTabs extends StatelessWidget {
  final List<Category> categories;
  final void Function(String categoryName) onRefresh;
  final void Function(String categoryName) onCategoryClick;

  const CategoryTabs({
    super.key,
    required this.categories,
    required this.onRefresh,
    required this.onCategoryClick,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40, // 确保 InkWell 能正确点击
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const SizedBox(width: 4),
                  ...categories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () {
                          debugPrint('点击了分类: ${category.label}');
                          // onRefresh(category.label);
                          onCategoryClick(category.label); // 确保这个方法被正确调用
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: category.color,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            category.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
