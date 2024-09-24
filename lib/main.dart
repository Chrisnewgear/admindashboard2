import 'package:admindashboard/constants/style.dart';
import 'package:admindashboard/controllers/navigation_controllers.dart';
import 'package:admindashboard/firebase_options.dart';
import 'package:admindashboard/layout.dart';
import 'package:admindashboard/pages/authentication/authentication.dart';
import 'package:admindashboard/routing/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:admindashboard/controllers/menu_controller.dart';
import 'pages/404/error.dart';

void main() async{
  Get.put(MyMenuController());
  Get.put(NavigationController());
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        return GetMaterialApp(
          initialRoute: authenticationPageRoute,
          unknownRoute: GetPage(name: "/not-found", page: () => const PageNotFound(), transition: Transition.downToUp),
          getPages: [
          GetPage(name: rootRoute, page: () => SiteLayout()),
          GetPage(name: authenticationPageRoute, page: () => const AuthenticationPage()),
          GetPage(name: pageNotFoundPageRoute, page: () => const PageNotFound()),
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
              //TargetPlatform.fuchsia: FadeUpwardsPageTransitionsBuilder(),
            }),
            primaryColor: Colors.blue
          ),
          //home: const AuthenticationPage(),
        );
      }
    );
  }
}
