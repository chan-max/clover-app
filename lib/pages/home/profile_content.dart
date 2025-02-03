import 'package:clover/pages/user/signin.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 导入 SharedPreferences
import 'package:clover/common/api.dart'; // 假设 getUserInfo 方法已在此文件中定义
// 替换成你的 SignInScreen 路径

class ProfileContent extends StatefulWidget {
  @override
  _ProfileContentState createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  dynamic userInfo; // 存储用户信息
  bool isLoading = true; // 控制加载状态

  @override
  void initState() {
    super.initState();
    _fetchUserInfo(); // 页面初始化时获取用户信息
  }

  // 获取用户信息的方法
  Future<void> _fetchUserInfo() async {
    try {
      final res = await getUserInfo(); // 调用接口获取用户信息
      setState(() {
        userInfo = res;
        isLoading = false; // 数据加载完成，更新状态
      });
    } catch (e) {
      setState(() {
        isLoading = false; // 即使发生错误，也结束加载状态
      });
      print('Error fetching user info: $e');
    }
  }

  // 退出登录方法
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // 清除存储的 Token
    print('Token 已清除，退出登录');

    // 使用页面过渡动画进行跳转
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return SignInScreen(); // 替换为 SignInScreen
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0); // 从右边滑入
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
              position: offsetAnimation, child: child); // 使用滑动过渡动画
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: isLoading
          ? const Center(child: CircularProgressIndicator()) // 显示加载指示器
          : SingleChildScrollView(
              child: Column(
                children: [
                  // 背景和头像部分
                  Stack(
                    children: [
                      // 背景
                      Container(
                        height: 180,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF00D0A9), Color(0xFF00796B)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      // 用户头像与用户名
                      Positioned(
                        bottom: -40,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: userInfo != null &&
                                        userInfo['avatar'] != null
                                    ? NetworkImage(userInfo['avatar']) // 动态加载头像
                                    : AssetImage(
                                            'assets/img/default-avatar.png')
                                        as ImageProvider, // 使用默认头像
                              ),
                              const SizedBox(height: 8),
                              Text(
                                userInfo?['username'] ?? '四叶草用户', // 动态显示用户名
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60), // 为头像下移提供空间
                  // 信息内容部分
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(thickness: 1),
                        _buildInfoRow(
                            '账号', userInfo?['username'] ?? '未知'), // 显示账号信息
                        const Divider(thickness: 1),
                        _buildInfoRow(
                            '联系方式',
                            (userInfo?['phone'] ?? '未知')
                                .toString()), // 确保phone是String类型
                        const Divider(thickness: 1),
                        _buildInfoRow(
                            '性别',
                            (userInfo?['gender'] ?? '未知')
                                .toString()), // 确保gender是String类型
                        const Divider(thickness: 1),
                        const SizedBox(height: 24),
                        // 编辑个人信息按钮
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              print('编辑个人信息');
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('编辑个人信息'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 12),
                              backgroundColor: const Color(0xFF00D0A9),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // 退出登录按钮
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: _logout, // 绑定退出登录方法
                            icon: const Icon(Icons.exit_to_app),
                            label: const Text('退出登录'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 12),
                              backgroundColor: Colors.red, // 退出按钮颜色
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // 构建每一行用户信息
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
