import 'package:admindashboard/constants/controllers.dart';
import 'package:admindashboard/constants/style.dart';
import 'package:admindashboard/helpers/responsiveness.dart';
import 'package:admindashboard/routing/routes.dart';
import 'package:admindashboard/widgets/custom_text.dart';
import 'package:admindashboard/widgets/side_menu_items.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// class SideMenu extends StatefulWidget {
//   const SideMenu({super.key});

//   @override
//   State<SideMenu> createState() => _SideMenuState();
// }

// class _SideMenuState extends State<SideMenu> {
//   bool isExpanded = true;

//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;

//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 200),
//       width: width,
//       color: light,
//       child: ListView(
//         children: [
//           IconButton(
//             icon: Icon(isExpanded ? Icons.arrow_back_ios : Icons.arrow_forward_ios),
//             onPressed: () {
//               setState(() {
//                 isExpanded = !isExpanded;
//               });
//             },
//           ),
//           if (ResponsiveWidget.isSmallScreen(context) && isExpanded)
//             Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const SizedBox(
//                   height: 40,
//                 ),
//                 Row(
//                   children: [
//                     SizedBox(width: width / 48),
//                     Padding(
//                       padding: const EdgeInsets.only(right: 12),
//                       child: Image.asset(
//                         "assets/icons/goSoftwareSolutions-01.png",
//                         height: 100,
//                         width: 100,
//                       ),
//                     ),
//                     Flexible(
//                       child: CustomText(
//                         text: "Dash",
//                         size: 20,
//                         weight: FontWeight.bold,
//                         color: active,
//                       ),
//                     ),
//                     SizedBox(width: width / 48),
//                   ],
//                 ),
//                 const SizedBox(
//                   height: 30,
//                 ),
//               ],
//             ),
//           Divider(
//             color: lightGrey.withOpacity(.1),
//           ),
//           FutureBuilder<List<MenuItem>>(
//             future: getSideMenuItemRoutes(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(
//                   child: CircularProgressIndicator(),
//                 );
//               }

//               if (snapshot.hasError) {
//                 return Center(
//                   child: Text('Error: ${snapshot.error}'),
//                 );
//               }

//               if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                 return const Center(
//                   child: Text('No menu items available'),
//                 );
//               }

//               return Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: snapshot.data!
//                     .map((item) => SideMenuItem(
//                           itemName: item.name,
//                           icon: item.icon ?? Icons.error, // Provide a default icon if null
//                           isExpanded: isExpanded,
//                           onTap: () {
//                             if (item.route == authenticationPageRoute) {
//                               Get.offAllNamed(authenticationPageRoute);
//                               menuController.changeActiveItemTo(overviewPageDisplayName);
//                             }
//                             if (!menuController.isActive(item.name)) {
//                               menuController.changeActiveItemTo(item.name);
//                               if (ResponsiveWidget.isSmallScreen(context)) {
//                                 Get.back();
//                               }
//                               navigationController.navigateTo(item.route);
//                             }
//                           },
//                         ))
//                     .toList(),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// ...existing imports...

class SideMenu extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback toggleExpanded;

  const SideMenu({
    super.key,
    required this.isExpanded,
    required this.toggleExpanded,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLargeScreen = !ResponsiveWidget.isSmallScreen(context);
    double width = isExpanded ? 150 : 70;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
      width: width,
      color: light,
      child: ListView(
        children: [
            IconButton(
              icon: Icon(isExpanded ? Icons.arrow_back_ios : Icons.arrow_forward_ios),
              onPressed: toggleExpanded
            ),
          if (ResponsiveWidget.isSmallScreen(context) && isExpanded)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 40),
                Row(
                  children: [
                    SizedBox(width: width / 48),
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Image.asset(
                        "assets/icons/goSoftwareSolutions-01.png",
                        height: 100,
                        width: 100,
                      ),
                    ),
                    Flexible(
                      child: CustomText(
                        text: "Dash",
                        size: 20,
                        weight: FontWeight.bold,
                        color: active,
                      ),
                    ),
                    SizedBox(width: width / 48),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          Divider(
            color: lightGrey.withOpacity(.1),
          ),
          FutureBuilder<List<MenuItem>>(
            future: getSideMenuItemRoutes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No menu items available'),
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: snapshot.data!
                    .map((item) => SideMenuItem(
                          itemName: item.name,
                          icon: menuController.returnIconFor(item.name),
                          isExpanded: isLargeScreen ? isExpanded : true,
                          onTap: () {
                            if (item.route == authenticationPageRoute) {
                              Get.offAllNamed(authenticationPageRoute);
                              menuController.changeActiveItemTo(overviewPageDisplayName);
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
              );
            },
          ),
        ],
      ),
    );
  }
}