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
    double _width = MediaQuery.of(context).size.width;

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
                    SizedBox(width: _width / 48),
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Image.asset("assets/icons/Logo-Techmall.webp"),
                    ),
                    Flexible(
                      child: CustomText(
                        text: "Dash",
                        size: 20,
                        color: active,
                        weight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: _width / 48),
                  ],
                ),
              ],
            ),
          const SizedBox(height: 40),
          Divider(color: lightGrey.withOpacity(.1)),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: sideMenuItems
                .map((itemName) => SideMenuItem(
                      itemName: itemName == AuthenticationPageRoute
                          ? "Log Out"
                          : itemName,
                      onTap: () {
                        if (itemName == AuthenticationPageRoute) {
                          //Navigator.of(context).pushNamedAndRemoveUntil(loginPageRoute, (route) => false);
                          //TODO - Implementar lógica de Logout
                        }

                        if (!menuController.isActive(itemName)) {
                          menuController.changeActiveItemTo(itemName);
                          if (ResponsiveWidget.isSmallScreen(context)) {
                            Get.back();
                            //TODO - Implementar lógica adicional si es necesario
                          }
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
