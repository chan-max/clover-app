import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '/common/provider.dart'; // 你的 Provider 文件

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
   
    final userInfo = Provider.of<AppDataProvider>(context, listen: true)
        .getData('userInfo');


    final dynamic coins = userInfo?['coin'] ?? '--'; // 获取时光币数，默认为 0

    final name = userInfo?['username'] ?? '--'; 

    return AppBar(
      backgroundColor: const Color(0xFF000000),
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            _getGreeting() + ' , ' + name ,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            softWrap: false,
            overflow: TextOverflow.visible,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: InkWell(
            onTap: () => _showTimeCoinInfo(context, coins),
            borderRadius: BorderRadius.circular(20),
            splashColor: Colors.white24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/img/coin.png',
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatCoins(coins),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
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

  String _formatCoins(dynamic coins) {
    return coins.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

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

void _showTimeCoinInfo(BuildContext context, dynamic coins) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black87, Colors.black54],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
            const SizedBox(height: 16), // 减少间距
            Image.asset('assets/img/coin.png', width: 100), // 缩小图片
            const SizedBox(height: 16), // 减少间距
            const Text(
              "时光币介绍",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20, // 缩小标题字体
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8), // 减少间距
            const Text(
              "时光币是一种虚拟货币，可用于兑换特定权益，如高级功能、会员特权、个性化装扮等。\n"
              "你可以通过每日任务、签到、活动奖励等方式获取更多时光币。",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14), // 缩小正文字体
            ),
            const SizedBox(height: 16), // 减少间距
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12), // 缩小内边距
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/img/coin.png', width: 24), // 缩小图片
                  const SizedBox(width: 8),
                  Text(
                    "当前余额: ${_formatCoins(coins)} 时光币",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14, // 缩小字体
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16), // 减少间距
            ElevatedButton(
              onPressed: () {
                Clipboard.setData(const ClipboardData(text: "https://your-recharge-url.com"));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("充值网址已复制")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // 缩小内边距
              ),
              child: const Text(
                "复制充值网址",
                style: TextStyle(color: Colors.white, fontSize: 14), // 缩小字体
              ),
            ),
            const SizedBox(height: 8), // 减少间距
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // 缩小内边距
              ),
              child: const Text(
                "查看每日任务",
                style: TextStyle(color: Colors.black, fontSize: 14), // 缩小字体
              ),
            ),
            const SizedBox(height: 8), // 减少间距
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // 缩小内边距
              ),
              child: const Text(
                "关闭",
                style: TextStyle(color: Colors.white, fontSize: 14), // 缩小字体
              ),
            ),
          ],
        ),
      );
    },
  );
}
}
