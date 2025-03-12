import 'package:clover/common/provider.dart';
import 'package:clover/common/style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import './signup.dart';
import 'package:clover/pages/home.dart';
import 'package:clover/common/api.dart'; // 导入封装的DioHttp
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clover/pages/common/intro.dart';
class SignInScreen extends StatefulWidget {
  SignInScreen({super.key});
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _username = '';
  String _password = '';

  void _navigateWithSlide(BuildContext context, Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

    try {
    await signin(_username, _password);
    Provider.of<AppDataProvider>(context, listen: false).fetchUserInfo();
    Get.offAndToNamed('/home');
  } catch (e) {
    TDToast.showText('登录失败', context: context);
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 黑色背景
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  SizedBox(height: constraints.maxHeight * 0.1),
                  Image.asset(
                    'assets/clover_heart.png',
                    height: 200,
                    width: 200,
                  ),
                  SizedBox(height: constraints.maxHeight * 0.1),
                  Text(
                    "登录四叶草",
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(fontWeight: FontWeight.bold, color: Colors.white,fontSize: 20),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.05),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          style: TextStyle(color: Colors.white,fontSize: 12),
                          decoration: InputDecoration(
                            hintText: '用户名',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            filled: true,
                            fillColor: Colors.grey[900], // 深灰色填充
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                            ),
                          ),
                          onSaved: (value) {
                            _username = value ?? '';
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: TextFormField(
                            obscureText: true,
                            style: TextStyle(color: Colors.white,fontSize: 12),
                            decoration: InputDecoration(
                              hintText: '密码',
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              filled: true,
                              fillColor: Colors.grey[900], // 深灰色填充
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 12.0),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50)),
                              ),
                            ),
                            onSaved: (value) {
                              _password = value ?? '';
                            },
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: PrimaryColor, // 亮绿色按钮
                            foregroundColor: Colors.black,
                            minimumSize: const Size(double.infinity, 48),
                            shape: const StadiumBorder(),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.0,
                                 
                                  ),
                                )
                              : const Text("登录",style: TextStyle(   fontWeight: FontWeight.bold,color: Colors.white)),
                        ),
                        const SizedBox(height: 16.0),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            '密码忘记了?',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: Colors.grey[500],
                                ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _navigateWithSlide(context, SignUpScreen());
                          },
                          child: Text.rich(
                            TextSpan(
                              text: "还没有账号吗 ",
                              children: [
                                TextSpan(
                                  text: "快速注册",
                                  style: TextStyle(color: PrimaryColor),
                                ),
                              ],
                            ),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: Colors.grey[500],
                                ),
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
}
