import 'package:flutter/material.dart';
import 'package:floating_bubbles/floating_bubbles.dart';
import 'package:word_cloud/word_cloud_data.dart';
import 'package:word_cloud/word_cloud_shape.dart';
import 'package:word_cloud/word_cloud_tap.dart';
import 'package:word_cloud/word_cloud_tap_view.dart';
import 'package:word_cloud/word_cloud_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clover/pages/user/signin.dart';
import 'package:clover/common/api.dart';
import './update.dart';
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  dynamic userInfo;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    try {
      final res = await getUserInfo();
      setState(() {
        userInfo = res;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching user info: $e');
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    print('Token 已清除，退出登录');

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return SignInScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Scaffold(
              backgroundColor: Color(0xffffffff),
              body: Column(
                children: [
                  Expanded(flex: 2, child: _TopPortion(userInfo: userInfo)),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            userInfo?['username'] ?? '四叶草用户',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditProfilePage(),
                                ),
                              );
                            },
                            label: const Text(
                              '编辑信息',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.grey,
                                fontSize: 12.0,
                              ),
                            ),
                            style: TextButton.styleFrom(),
                          ),
                          const SizedBox(height: 12),
                          const _ProfileInfoRow(),
                          const SizedBox(height: 12),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: _logout,
                              icon: const Icon(Icons.exit_to_app),
                              label: const Text('退出登录'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 12),
                                backgroundColor: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({super.key});

  final List<ProfileInfoItem> _items = const [
    ProfileInfoItem("已加入", 900),
    ProfileInfoItem("Following", 200),
    ProfileInfoItem("Following", 200),
    ProfileInfoItem("Following", 200),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      constraints: const BoxConstraints(maxWidth: 400),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _items
            .map((item) => Expanded(
                    child: Row(
                  children: [
                    if (_items.indexOf(item) != 0) const VerticalDivider(),
                    Expanded(child: _singleItem(context, item)),
                  ],
                )))
            .toList(),
      ),
    );
  }

  Widget _singleItem(BuildContext context, ProfileInfoItem item) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              item.value.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          Text(
            item.title,
            style: Theme.of(context).textTheme.bodySmall,
          )
        ],
      );
}

class ProfileInfoItem {
  final String title;
  final int value;
  const ProfileInfoItem(this.title, this.value);
}

class _TopPortion extends StatelessWidget {
  const _TopPortion({super.key, required this.userInfo});

  final dynamic userInfo;

  @override
  Widget build(BuildContext context) {
    List<Map> wordList = [
      {'word': '早点睡', 'value': 100},
      {'word': '多喝水', 'value': 60},
      {'word': '冥想', 'value': 55},
      {'word': '放松', 'value': 50},
      {'word': '今天吃点啥', 'value': 40},
      {'word': '要存钱啊', 'value': 35},
      {'word': '每天都开开心心', 'value': 12},
      {'word': '我是谁', 'value': 27},
      {'word': '学习不止', 'value': 27},
      {'word': '今天咋样', 'value': 26},
      {'word': '哈哈哈', 'value': 25},
      {'word': '不知道啊', 'value': 25},
    ];

    WordCloudData wcData = WordCloudData(
      data: wordList,
      // minSize: 8.0, // 设置最小字体大小
      // maxSize: 20.0, // 设置最大字体大小
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        // 这个背景放在最底层
        Container(
          margin: const EdgeInsets.only(bottom: 50),
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0x6678ffd6), Color(0xccffffff)]),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              )),
        ),
        // 词云效果放在最底层
        // Positioned(
        //   top: 50,
        //   left: 0,
        //   right: 0,
        //   child: WordCloudView(
        //     data: wcData,
        //     mapcolor: Colors.transparent,
        //     mapwidth: MediaQuery.of(context).size.width,
        //     mapheight: 250,
        //     fontWeight: FontWeight.bold,
        //     colorlist: [Colors.grey, Colors.blueAccent, Colors.redAccent],
        //     // minFontSize: 8.0, // 设置最小字体大小
        //     // maxFontSize: 20.0, // 设置最大字体大小
        //   ),
        // ),
        // 顶部操作按钮（设置、编辑等）
        Positioned(
          left: 16,
          top: 16,
          child: IconButton(
            icon: const Icon(Icons.settings, color: Colors.grey),
            onPressed: () {
              print("跳转到设置页面");
            },
          ),
        ),
        Positioned(
          right: 16,
          top: 16,
          child: IconButton(
            icon: const Icon(Icons.edit, color: Colors.grey),
            onPressed: () {
              print("跳转到编辑页面");
            },
          ),
        ),
        Positioned(
          right: 16,
          top: 64,
          child: IconButton(
            icon: const Icon(Icons.notifications, color: Colors.grey),
            onPressed: () {
              print("跳转到消息页面");
            },
          ),
        ),
        Positioned(
          right: 16,
          top: 112,
          child: IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.grey),
            onPressed: () {
              print("跳转到帮助页面");
            },
          ),
        ),
        // 用户头像部分
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(userInfo?['avatar'] ??
                            'https://default-avatar-image-url.com')),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      decoration: const BoxDecoration(
                          color: Colors.green, shape: BoxShape.circle),
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
