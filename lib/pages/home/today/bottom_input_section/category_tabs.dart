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
      height: 35, // 调整高度使每个元素更小
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
                      child: InkWell(
                        onTap: () {
                          debugPrint('点击了分类: ${category.label}');
                          onCategoryClick(category.label); // 调用点击事件
                        },
                        splashColor: Colors.white.withOpacity(0.4), // 点击时的涟漪效果
                        highlightColor: Colors.white.withOpacity(0.2), // 点击时的高亮效果
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // 调整内边距
                          decoration: BoxDecoration(
                            color: category.color,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            category.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12, // 减小文字大小
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
