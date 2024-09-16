import 'package:admindashboard/constants/style.dart';
import 'package:admindashboard/controllers/navigation_controllers.dart';
import 'package:admindashboard/layout.dart';
import 'package:admindashboard/pages/authentication/authentication.dart';
import 'package:admindashboard/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:admindashboard/controllers/menu_controller.dart';
import 'pages/404/error.dart';

void main(){
  Get.put(MyMenuController());
  Get.put(NavigationController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: authenticationPageRoute,
      unknownRoute: GetPage(name: "not-found", page: () => const PageNotFound(), 
        transition: Transition.fadeIn),
      getPages: [
        GetPage(name: rootRoute, page: () => SiteLayout()),
        GetPage(name: authenticationPageRoute, page: () => const AuthenticationPage()),
      ],
      debugShowCheckedModeBanner: false,
      title: "Dashboard",
      theme: ThemeData(
        scaffoldBackgroundColor: light,
        textTheme: GoogleFonts.mulishTextTheme(
          Theme.of(context).textTheme
        ).apply(
          bodyColor: Colors.black
        ),
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        }),
        primaryColor: Colors.blue
      ),
      //home: const AuthenticationPage(),
    );
  }
}
