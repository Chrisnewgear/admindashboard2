import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class NavigationController extends GetxController {
  static NavigationController instance = Get.find();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  Future<void> navigateTo(String routeName) async {
    try {
      await navigatorKey.currentState!.pushNamed(routeName);
    } catch (e) {
      await navigatorKey.currentState!.pushNamed('/not-found');
    }
  }

  goBack() => navigatorKey.currentState?.pop();
}