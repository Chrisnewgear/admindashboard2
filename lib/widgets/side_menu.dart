import 'package:admindashboard/constants/controllers.dart';
import 'package:admindashboard/constants/style.dart';
import 'package:admindashboard/helpers/responsiveness.dart';
import 'package:admindashboard/routing/routes.dart';
import 'package:admindashboard/widgets/custom_text.dart';
import 'package:admindashboard/widgets/side_menu_items.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Container(
      color: light,
      child: ListView(
        children: [
          if (ResponsiveWidget.isSmallScreen(context))
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 40,
                ),
                Row(
                  children: [
                    SizedBox(width: width / 48),
                    Padding(
                      padding: const EdgeInsets.only(right:12),
                      child: Image.asset("assets/icons/Logo-Techmall.webp", width: 100, height: 100,),
                    ),
                    Flexible(
                      child: CustomText(
                        text: "Dashboard",
                        size: 20,
                        color: active,
                        weight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: width / 48),
                  ],
                ),
              ],
            ),
          //const SizedBox(height: 40),
          Divider(color: lightGrey.withOpacity(.1)),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: sideMenuItemRoutes
                .map((item) => SideMenuItem(
                      itemName:   item.name,
                      onTap: () {
                        if (item.route == authenticationPageRoute) {
                          menuController.changeActiveItemTo(overviewPageDisplayName);
                          Get.offAllNamed(authenticationPageRoute);
                        }

                        if (!menuController.isActive(item.name)) {
                          menuController.changeActiveItemTo(item.name);
                          if (ResponsiveWidget.isSmallScreen(context)) {
                            Get.back();
                          }
                          navigationController.navigateTo(item.route);
                        }
                      },
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
