import 'package:admindashboard/constants/style.dart';
import 'package:admindashboard/helpers/responsiveness.dart';
import 'package:admindashboard/widgets/custom_text.dart';
import 'package:flutter/material.dart';

AppBar topNavigationBar(BuildContext context, GlobalKey<ScaffoldState> Key) =>
    AppBar(
      leading: !ResponsiveWidget.isSmallScreen(context)
          ? Row(
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 14),
                  child: Image.asset("assets/icons/Logo-Techmall.webp", width: 30),
                )
              ],
            )
          : IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Key.currentState!.openDrawer();
              },
            ),
      elevation: 0,
      title: Row(
        children: [
          Visibility(child: CustomText(text: "Dash", color: lightGrey, size: 20, weight: FontWeight.bold,)),
          Expanded(child: Container()),
          IconButton(
              icon: Icon(
                Icons.settings,
                color: dark.withOpacity(.7),),
              onPressed: () {},
            ),
          Stack(
            children: [
              IconButton(icon: Icon(
                Icons.settings,
                color: dark.withOpacity(.7)),
                onPressed: () {}),
                Positioned(child: Container(
                  width: 12,
                  height: 12,
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: active,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: light,
                      width: 2
                    )
                  )
                )
              )
            ]
          ),

          Container(
            width: 1,
            height: 22,
            color: lightGrey,
          )
        ],
      )
      //backgroundColor: Colors.white,
    );
