import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:clover/common/api.dart'; // 假设你有一个 API 文件
import 'package:clover/common/provider.dart'; // 引入 AppDataProvider

class CompleteInfoPage extends StatefulWidget {
  const CompleteInfoPage({super.key});

  @override
  _CompleteInfoPageState createState() => _CompleteInfoPageState();
}

class _CompleteInfoPageState extends State<CompleteInfoPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late int _gender; // 性别
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo(); // 获取用户信息
  }

  Future<void> _fetchUserInfo() async {
    try {
      // 从 AppDataProvider 获取用户信息
      final appDataProvider = Provider.of<AppDataProvider>(context, listen: false);
      final userInfo = appDataProvider.getData('userInfo'); // 直接从 Provider 中获取数据

      setState(() {
        _phoneController = TextEditingController(text: userInfo['phone'] ?? '');
        _emailController = TextEditingController(text: userInfo['email'] ?? '');
        _gender = userInfo['gender'] ?? 1; // 默认性别为男性
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching user info: $e');
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      // 更新用户信息的API调用
      final updatedUserInfo = {
        'phone': _phoneController.text,
        'email': _emailController.text,
        'gender': _gender,
        'shouldComplete':0
      };

      try {
        final res = await updateUserInfo(updatedUserInfo); // 假设你有这个方法来更新信息
        if (res) {
          TDToast.showText('信息更新成功', context: context);
         await Provider.of<AppDataProvider>(context, listen: false).fetchUserInfo();
          Get.offAndToNamed('/home');
        } else {
          TDToast.showText('信息更新失败', context: context);
        }
      } catch (e) {
        TDToast.showText('信息更新失败', context: context);
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        titleTextStyle:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        title: const Text('完善个人信息'),
        iconTheme: const IconThemeData(color: Colors.grey),
        automaticallyImplyLeading: false, // 禁用返回按钮
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // 加载状态
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      '请完善以下信息以继续使用',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: '手机号',
                        hintText: '请输入手机号',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '手机号不能为空';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: '邮箱',
                        hintText: '请输入邮箱',
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '邮箱不能为空';
                        } else if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                          return '请输入有效的邮箱';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // 性别选择
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.grey),
                        const SizedBox(width: 10),
                        const Text('性别', style: TextStyle(fontSize: 16)),
                        const Spacer(),
                        DropdownButton<int>(
                          value: _gender,
                          items: [
                            DropdownMenuItem(
                              value: 1,
                              child: Text('男'),
                            ),
                            DropdownMenuItem(
                              value: 0,
                              child: Text('女'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _gender = value!;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _saveProfile,
                      icon: const Icon(Icons.save),
                      label: const Text('保存并继续'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}