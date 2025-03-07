
import 'package:get/get.dart';
import 'package:clover/pages/common/intro.dart';
import 'package:clover/pages/home.dart';
import 'package:clover/pages/user/signin.dart';
import 'package:clover/pages/user/signup.dart';
class AppPage {
  static final routes = [
    GetPage(
        name: "/",
        page: () =>  HomePage(),
        transition: Transition.leftToRight),
        GetPage(
        name: "/home",
        page: () =>  HomePage(),
        transition: Transition.leftToRight),
    GetPage(name: "/signin", page: () => SignInScreen()),
    GetPage(name: "/signup", page: () => SignInScreen()),
    GetPage(name: "/intro", page: () => IntroScreen()),
  ];
}