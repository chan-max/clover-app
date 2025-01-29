import 'package:flutter/material.dart';
import '/common/provider.dart'; // 引入 provider
import 'package:provider/provider.dart'; // 引入 provider
import '/common/record/record.dart';
class DayRecordCard extends StatelessWidget {
  const DayRecordCard({super.key});

  @override
  Widget build(BuildContext context) {
    // 从 Provider 获取 dayRecord 数据
    var dayRecord = Provider.of<AppDataProvider>(context).getData('dayrecord');

    // 统计每个类型的记录条数
    Map<String, int> recordCount = {};
    if (dayRecord != null && dayRecord['record'] != null) {
      for (var record in dayRecord['record']) {
        String type = record['type'];
        recordCount[type] = (recordCount[type] ?? 0) + 1;
      }
    }

    return Container(
      width: double.infinity, // 宽度占满父容器
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // 外边距缩小
      decoration: BoxDecoration(
        color: const Color(0xffffffff), // 背景颜色
        borderRadius: BorderRadius.circular(8), // 圆角缩小
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(149, 157, 165, 0.2), // 阴影颜色
            offset: const Offset(0, 4), // 阴影偏移量减小
            blurRadius: 12, // 模糊半径减小
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16), // 内边距缩小
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // 水平居中
              mainAxisAlignment: MainAxisAlignment.center, // 垂直居中
              mainAxisSize: MainAxisSize.min, // 高度随内容调整
              children: [
                // 添加图片
                Center(
                  child: Image.asset(
                    'assets/img/home/home-record.png', // 图片路径
                    width: 80, // 缩小图片宽度
                    height: 80, // 缩小图片高度
                  ),
                ),
                const SizedBox(height: 12), // 图片和内容之间的间距缩小

                // 使用 Container 为文本设置底部边框
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xff00D0A9), // 设置下划线的颜色
                        width: 2.0, // 设置下划线的宽度缩小
                      ),
                    ),
                  ),
                  child: Text.rich(
                    TextSpan(
                      text: '今天共添加了 ', // 普通文本
                      style: const TextStyle(
                        fontSize: 12, // 字体大小缩小
                        fontWeight: FontWeight.bold,
                        color: Color(0xff777777),
                      ),
                      children: [
                        TextSpan(
                          text:
                              '${dayRecord?['record']?.length ?? '?'}', // 记录条数，默认为 `?`
                          style: const TextStyle(
                            fontSize: 24, // 字体大小缩小
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 16, 13, 13),
                          ),
                        ),
                        TextSpan(
                          text: ' 条记录', // 普通文本
                          style: const TextStyle(
                            fontSize: 12, // 字体大小缩小
                            fontWeight: FontWeight.bold,
                            color: Color(0xff777777),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24), // 间距缩小

                // 使用 Wrap 组件来替代 GridView，进行类似 flex 布局的排列
                Wrap(
                  alignment: WrapAlignment.center, // 水平居中
                  runSpacing: 6, // 垂直方向的间距缩小
                  spacing: 16, // 水平方向的间距缩小
                  children: recordTypeOptions.map<Widget>((option) {
                    String type = option['type'];
                    int count = recordCount[type] ?? 0; // 获取该类型的记录条数，默认 0

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$count', // 显示记录条数
                          style: const TextStyle(
                            fontSize: 16, // 字体大小缩小
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 16, 13, 13),
                          ),
                        ),
                        const SizedBox(height: 2), // 减小间距
                        Text(
                          option['label'], // 显示标签
                          style: const TextStyle(
                            fontSize: 8, // 字体大小缩小
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24), // 调整按钮与内容之间的间距缩小

                // 下方的三个按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildButton('按钮 1', Icons.add),
                    _buildButton('按钮 2', Icons.edit),
                    _buildButton('按钮 3', Icons.check),
                  ],
                ),
              ],
            ),
          ),
          // 左上角查看详情图标按钮
          _buildIconButton(Icons.info_outline, Alignment.topLeft),
          // 右上角设置图标按钮
          _buildIconButton(Icons.settings, Alignment.topRight),
        ],
      ),
    );
  }

  // 按钮构建方法
  Widget _buildButton(String label, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {
        print('$label pressed');
      },
      icon: Icon(icon, size: 10, color: Colors.white), // 图标缩小
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 10, // 字体大小缩小
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff00D0A9),
        minimumSize: const Size(80, 30), // 按钮大小缩小
      ),
    );
  }

  // 图标按钮构建方法
  Widget _buildIconButton(IconData icon, Alignment alignment) {
    return Positioned(
      top: 4,
      left: alignment == Alignment.topLeft ? 4 : null,
      right: alignment == Alignment.topRight ? 4 : null,
      child: IconButton(
        icon: Icon(icon, size: 16, color: Colors.grey[350]), // 图标缩小
        onPressed: () => print('$icon pressed'),
      ),
    );
  }
}
