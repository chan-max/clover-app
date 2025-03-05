import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF000000), // 黑色背景
      elevation: 0, // 移除阴影
      // 左侧问候语
leading: Padding(
  padding: const EdgeInsets.only(left: 16), // 增加左侧间距
  child: Align(
    alignment: Alignment.centerLeft, // 让文字垂直居中
    child: Text(
      _getGreeting(),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16, // 增大字体
        fontWeight: FontWeight.bold,
      ),
      softWrap: false, // 不允许换行
      overflow: TextOverflow.visible, // 超出时显示省略号
    ),
  ),
),



      // 右侧按钮
  actions: [
  Padding(
    padding: const EdgeInsets.only(right: 4), // 右侧间距
    child: InkWell(
      onTap: () => _showTimeCoinInfo(context), // 点击后弹出金币介绍弹层
      borderRadius: BorderRadius.circular(20), // 圆角效果
      splashColor: Colors.white24, // 点击时的涟漪效果
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2), // 轻微透明背景
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Image.asset(
              'assets/img/coin.png',
              width: 24, // 适当缩小尺寸
              height: 24,
            ),
            const SizedBox(width: 4), // 图片与文字间距
            Text(
              _formatCoins(1234567), // 你的金币数
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ),
  ),
],


    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

String _formatCoins(int coins) {
  return coins.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'), 
    (match) => '${match[1]},',
  );
}

  /// 获取当前时间段的问候语
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) {
      return "Hi, 凌晨好";
    } else if (hour < 12) {
      return "Hi, 早上好";
    } else if (hour < 18) {
      return "Hi, 下午好";
    } else {
      return "Hi, 晚上好";
    }
  }


  void _showTimeCoinInfo(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.75, // 75% 屏幕高度
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "时光币介绍",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "时光币是一种虚拟货币，可用于兑换特定权益，如会员功能、虚拟道具等。",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Image.asset('assets/img/coin.png', width: 40),
                const SizedBox(width: 8),
                const Text(
                  "当前余额: 1,234,567 时光币",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Center(
                child: Text(
                  "关闭",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}


}
