import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clover/common/api.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart'; // 假设你有一个 API 用来更新用户信息

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _birthdayController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late String _avatarUrl;
  late int _gender; // 性别
  final _imagePicker = ImagePicker();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo(); // 获取用户信息
  }

  Future<void> _fetchUserInfo() async {
    try {
      final res = await getUserInfo(); // 假设你有一个方法获取用户信息
      setState(() {
        _usernameController = TextEditingController(text: res['username']);
        _birthdayController = TextEditingController(text: res['birthday']);
        _phoneController = TextEditingController(text: res['phone']);
        _emailController = TextEditingController(text: res['email']);
        _avatarUrl = res['avatar'];
        _gender = res['gender'] ?? 1; // 默认性别为男性
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching user info: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatarUrl = pickedFile.path; // 你可以根据上传服务器的需求来处理
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      // 更新用户信息的API调用
      final updatedUserInfo = {
        'birthday': _birthdayController.text,
        'avatar': _avatarUrl,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'gender': _gender,
      };

      try {
        final res = await updateUserInfo(updatedUserInfo); // 假设你有这个方法来更新信息
        if (res) {
          TDToast.showText('信息更新成功', context: context);
          Navigator.pop(context);
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
    _usernameController.dispose();
    _birthdayController.dispose();
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
        title: const Text('编辑个人资料'),
        iconTheme: const IconThemeData(color: Colors.grey),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // 加载状态
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(_avatarUrl),
                        child:
                            const Icon(Icons.camera_alt, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 用户名字段不可修改
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: '用户名',
                        hintText: '用户名不可修改',
                        prefixIcon: Icon(Icons.person),
                      ),
                      enabled: false, // 设置为不可编辑
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _birthdayController,
                      decoration: const InputDecoration(
                        labelText: '生日',
                        hintText: '请选择生日',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '生日不能为空';
                        }
                        return null;
                      },
                      onTap: () async {
                        FocusScope.of(context).requestFocus(FocusNode());
                        DateTime? selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (selectedDate != null) {
                          setState(() {
                            _birthdayController.text =
                                selectedDate.toIso8601String().split('T')[0];
                          });
                        }
                      },
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
                      label: const Text('保存'),
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
