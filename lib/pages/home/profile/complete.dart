import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:clover/common/api.dart'; // 假设你有一个 API 文件
import 'package:clover/common/provider.dart'; // 引入 AppDataProvider
import 'package:clover/common/style.dart'; // 引入 PrimaryColor

class CompleteInfoPage extends StatefulWidget {
  const CompleteInfoPage({super.key});

  @override
  _CompleteInfoPageState createState() => _CompleteInfoPageState();
}

class _CompleteInfoPageState extends State<CompleteInfoPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _birthdayController;
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
        _nameController = TextEditingController(text: userInfo['name'] ?? '');
        _phoneController = TextEditingController(text: userInfo['phone'] ?? '');
        _emailController = TextEditingController(text: userInfo['email'] ?? '');
        _birthdayController = TextEditingController(text: userInfo['birthday'] ?? '');
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
        'name': _nameController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'birthday': _birthdayController.text,
        'gender': _gender,
        'shouldComplete': 0
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: PrimaryColor, // 使用 PrimaryColor
              surface: Colors.grey[850]!,
            ),
            dialogBackgroundColor: Colors.grey[900],
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _birthdayController.text = "${picked.year}-${picked.month}-${picked.day}";
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        brightness: Brightness.dark, // 使用暗色主题
        primaryColor: PrimaryColor, // 使用 PrimaryColor
        colorScheme: ColorScheme.dark(
          primary: PrimaryColor,
          secondary: PrimaryColor.withOpacity(0.8),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[850],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: PrimaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          titleTextStyle:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                      const SizedBox(height: 10),
                      const Text(
                        '这些信息可能会在未来使用到，请确保填写准确。',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: '昵称',
                          hintText: '请输入昵称',
                          prefixIcon: Icon(Icons.person, color: Colors.grey),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '昵称不能为空';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: '手机号',
                          hintText: '请输入手机号',
                          prefixIcon: Icon(Icons.phone, color: Colors.grey),
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
                          prefixIcon: Icon(Icons.email, color: Colors.grey),
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
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: _birthdayController,
                            decoration: const InputDecoration(
                              labelText: '生日',
                              hintText: '请选择生日',
                              prefixIcon: Icon(Icons.cake, color: Colors.grey),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '生日不能为空';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // 性别选择
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[850],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.person, color: Colors.grey),
                            const SizedBox(width: 10),
                            const Text('性别', style: TextStyle(fontSize: 16, color: Colors.white)),
                            const Spacer(),
                            DropdownButton<int>(
                              value: _gender,
                              dropdownColor: Colors.grey[850],
                              style: const TextStyle(color: Colors.white),
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
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PrimaryColor, // 使用 PrimaryColor
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('保存并继续', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}