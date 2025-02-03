import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 引入 provider
import '/common/provider.dart'; // 引入 AppDataProvider
import '/common/record/record.dart'; // 导入 recordTypeOptions 数据结构
import 'package:smooth_page_indicator/smooth_page_indicator.dart'; // 引入分页指示器

// RecordTypeBottomSheet 的状态类
class RecordTypeBottomSheet extends StatefulWidget {
  final Function(String) onOptionSelected; // 传递一个回调函数

  const RecordTypeBottomSheet({super.key, required this.onOptionSelected});

  @override
  _RecordTypeBottomSheetState createState() => _RecordTypeBottomSheetState();
}

class _RecordTypeBottomSheetState extends State<RecordTypeBottomSheet> {
  bool isLoading = true; // 控制加载状态
  late PageController _pageController; // 用来控制 PageView
  int currentPage = 0; // 当前页数

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fetchDayrecord(); // 初始化时调用接口
  }

  // 从 AppDataProvider 中获取 dayrecord 数据
  void _fetchDayrecord() {
    final dayrecord = Provider.of<AppDataProvider>(context, listen: false)
        .getData('dayrecord');

    // 如果数据存在，进行处理
    if (dayrecord != null && dayrecord['record'] != null) {
      setState(() {
        isLoading = false; // 设置加载状态为 false
      });
    } else {
      setState(() {
        isLoading = false; // 如果没有数据，设置加载状态为 false
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 将数据分为两行四个元素
    final pages = List.generate(
      (recordTypeOptions.length / 8).ceil(),
      (index) => recordTypeOptions.skip(index * 8).take(8).toList(),
    );

    return SafeArea(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // 点击时关闭键盘
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
              vertical: 16.0, horizontal: 16), // 给弹窗左右添加边距
          decoration: BoxDecoration(
            color: Colors.grey.shade50, // 改为浅灰色的背景
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16), // 调整圆角
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // 自适应高度
            children: [
              // 工具栏（可以自定义内容）
              Container(
                height: 50, // 工具栏的高度
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 6.0,
                      spreadRadius: 1.0,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
                      Text(
                        '', // 工具栏标题
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Icon(Icons.search,
                          size: 20, color: Colors.black), // 你可以根据需要添加更多图标或按钮
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16), // 工具栏与下面内容的间距

              // PageView 用于分页
              SizedBox(
                height: 200, // 限制最大高度为屏幕的一半，可以根据需要调整
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: pages.length, // 页数
                  onPageChanged: (index) {
                    setState(() {
                      currentPage = index; // 更新当前页数
                    });
                  },
                  itemBuilder: (context, pageIndex) {
                    final page = pages[pageIndex];

                    return GridView.builder(
                      padding: EdgeInsets.zero, // 去掉 GridView 默认的边距
                      shrinkWrap: true, // 保持 GridView 高度自适应
                      physics:
                          NeverScrollableScrollPhysics(), // 禁止内部 GridView 滚动
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4, // 每行4个方块
                        crossAxisSpacing: 12, // 横向间距
                        mainAxisSpacing: 12, // 纵向间距
                      ),
                      itemCount: page.length, // 当前页的元素数量
                      itemBuilder: (context, index) {
                        final option = page[index]; // 获取当前数据项

                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context); // 关闭底部弹窗
                            widget.onOptionSelected(option['type']); // 调用回调函数
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white, // 设置卡片背景色为白色
                              borderRadius: BorderRadius.circular(12), // 圆角
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade100,
                                  blurRadius: 6.0, // 微弱的模糊阴影
                                  spreadRadius: .2, // 阴影扩展范围
                                ),
                              ],
                            ),
                            child: IntrinsicHeight(
                              // 使用 IntrinsicHeight 来让卡片自适应高度
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 12.0),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center, // 内容垂直居中
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min, // 自动调整内容高度
                                  children: [
                                    Image.asset(
                                      option['logo'],
                                      width: 24,
                                      height: 24,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      option['label'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Colors.black, // 文字颜色为黑色
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              // 分页圆点指示器
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: pages.length, // 页数
                  effect: WormEffect(
                    dotWidth: 10,
                    dotHeight: 10,
                    spacing: 8,
                    dotColor: Colors.grey.shade400, // 更加柔和的点颜色
                    activeDotColor: Colors.green.shade500, // 更显眼的活动点颜色
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
