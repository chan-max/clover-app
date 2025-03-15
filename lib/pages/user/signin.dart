import 'package:clover/common/provider.dart';
import 'package:clover/common/style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:clover/pages/home.dart';
import 'package:clover/common/api.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './signup.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _username = '';
  String _password = '';
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _usernameController.text = prefs.getString('saved_username') ?? '';
      _passwordController.text = prefs.getString('saved_password') ?? '';
    });
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      try {
        await signin(_username, _password);
        Provider.of<AppDataProvider>(context, listen: false).fetchUserInfo();
        
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_username', _username);
        await prefs.setString('saved_password', _password);
        
        Get.offAndToNamed('/home');
      } catch (e) {
        TDToast.showText('登录失败', context: context);
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  SizedBox(height: constraints.maxHeight * 0.1),
                  Image.asset('assets/clover_heart.png', height: 200, width: 200),
                  SizedBox(height: constraints.maxHeight * 0.1),
                  Text(
                    "登录四叶草",
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.05),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _usernameController,
                          style: TextStyle(color: Colors.white, fontSize: 12),
                          decoration: _inputDecoration('用户名'),
                          onSaved: (value) => _username = value ?? '',
                        ),
                        SizedBox(height: 16.0),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          style: TextStyle(color: Colors.white, fontSize: 12),
                          decoration: _inputDecoration('密码'),
                          onSaved: (value) => _password = value ?? '',
                        ),
                        SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: PrimaryColor,
                            foregroundColor: Colors.black,
                            minimumSize: const Size(double.infinity, 48),
                            shape: const StadiumBorder(),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24, height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.0),
                                )
                              : const Text("登录", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                        SizedBox(height: 16.0),
                        TextButton(
                          onPressed: () {},
                          child: Text('密码忘记了?',
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey[500]),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Get.to(() => SignUpScreen()),
                          child: Text.rich(
                            TextSpan(
                              text: "还没有账号吗 ",
                              children: [TextSpan(text: "快速注册", style: TextStyle(color: PrimaryColor))],
                            ),
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey[500]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[500]),
      filled: true,
      fillColor: Colors.grey[900],
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(50)),
      ),
    );
  }
}