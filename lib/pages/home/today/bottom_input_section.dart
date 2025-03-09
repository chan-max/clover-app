import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '/common/provider.dart';
import '/common/api.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

class BottomInputSection extends StatefulWidget {
  @override
  _BottomInputSectionState createState() => _BottomInputSectionState();
}

class _BottomInputSectionState extends State<BottomInputSection>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode(); // 添加 FocusNode

  bool _isInputVisible = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // 初始化动画控制器
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    // 初始化滑动动画
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5), // 从下方滑入
      end: Offset.zero, // 滑动到正常位置
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose(); // 释放 FocusNode
    _animationController.dispose(); // 释放动画控制器
    super.dispose();
  }

  void _addRecord() async {
    String inputText = _controller.text.trim();

    if (inputText.isEmpty) {
      TDToast.showWarning('请输入内容',
          direction: IconTextDirection.horizontal, context: context);
      return;
    }

    var params = {
      'content': inputText,
      'type': 'prompt',
    };

    try {
      await addDayRecordDetail(null, params);
      Provider.of<AppDataProvider>(context, listen: false).fetchDayRecord();

      TDToast.showText('记录添加成功', context: context);
      _controller.clear();
      setState(() {
        _isInputVisible = false; // 添加成功后关闭输入框和按钮
      });
      _animationController.reverse(); // 关闭时反向播放动画
    } catch (e) {
      TDToast.showText('添加失败请重试', context: context);
    }
  }

  void _showInputSection() {
    setState(() {
      _isInputVisible = true;
    });
    // 显示输入框后请求焦点
    Future.delayed(Duration(milliseconds: 100), () {
      FocusScope.of(context).requestFocus(_focusNode);
    });
    _animationController.forward(); // 显示时播放动画
  }

  void _closeInputSection() {
    setState(() {
      _isInputVisible = false;
    });
    // 关闭输入框后移除焦点
    _focusNode.unfocus();
    _animationController.reverse(); // 关闭时反向播放动画
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 蒙层（覆盖整个屏幕，包括状态栏和导航栏）
        if (_isInputVisible)
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeInputSection, // 点击蒙层时关闭
              behavior: HitTestBehavior.opaque, // 确保蒙层可以捕获点击事件
              child: Container(
                color: Colors.black.withOpacity(0.6), // 黑色带透明度
              ),
            ),
          ),
        // 输入框和按钮区域（放在蒙层之上）
        Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isInputVisible)
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _animationController,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            // 空白区域，后续可以添加内容
                            SizedBox(height: 6), // 留出空白区域
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // 左侧占位
                                SizedBox(width: 48), // 保持与关闭按钮对称
                                // 关闭按钮
                                IconButton(
                                  icon: Icon(Icons.close, color: Colors.white),
                                  onPressed: _closeInputSection, // 点击关闭按钮时关闭输入状态
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: 6),
                GestureDetector(
                  onTap: _showInputSection, // 点击输入框时显示按钮
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode, // 使用 FocusNode
                    enabled: _isInputVisible, // 如果输入框已显示，则启用输入
                    style: TextStyle(color: Colors.white,fontSize: 11,),
                    decoration: InputDecoration(
                      hintText: '记录一下',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                if (_isInputVisible)
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _animationController,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6.0, bottom: 6.0), // 增加底部间距
                        child: Row(
                          children: [
                            // 左侧的其他内容
                            SizedBox(width: 4,),
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(Icons.photo_camera, color: Colors.white), // 示例：相机图标
                                  SizedBox(width: 8),
                                  Icon(Icons.attach_file, color: Colors.white), // 示例：附件图标
                                ],
                              ),
                            ),
                            // 保存记录按钮
             SizedBox(
  height: 32,
  width: 72, // 限制高度
  child: ElevatedButton(
    onPressed: _addRecord,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.greenAccent,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.zero, // 去掉内边距
      tapTargetSize: MaterialTapTargetSize.shrinkWrap, // 让点击区域紧贴按钮
    ),
    child: Text(
      "保存记录",
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
    ),
  ),
)



                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}