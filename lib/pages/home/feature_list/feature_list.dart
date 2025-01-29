import 'package:flutter/material.dart';

class FeatureList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 示例数据，可以根据实际需求进行替换
    final List<String> items =
        List.generate(50, (index) => 'Feature Item #$index');

    return SafeArea(
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(items[index]),
            subtitle: Text('This is a feature description.'),
            leading: Icon(Icons.star),
          );
        },
      ),
    );
  }
}
