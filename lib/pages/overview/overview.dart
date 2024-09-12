import 'package:admindashboard/constants/controllers.dart';
import 'package:admindashboard/helpers/responsiveness.dart';
import 'package:admindashboard/pages/overview/widgets/overview_card_large.dart';
import 'package:admindashboard/pages/overview/widgets/overview_card_medium.dart';
import 'package:admindashboard/pages/overview/widgets/overview_card_small.dart';
import 'package:admindashboard/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        Obx(() => Row(
          children: [
            Container(
              margin: EdgeInsets.only(top:
              ResponsiveWidget.isSmallScreen(context) ? 56 : 6),
              child: CustomText(
                text: menuController.activeItem.value,
                size: 20,
                weight: FontWeight.bold,
              ),
            )
          ],
        )),

        Expanded(
          child: ListView(
            children: [
              if(ResponsiveWidget.isLargeScreen(context) || 
                ResponsiveWidget.isMediumScreen(context))
                  if(ResponsiveWidget.isCustomScreen(context))
                    const OverviewCardMediumScreen()
                  else
                    const OverviewCardsLargeScreen()
              else
                const OverViewCardSmallScreen()
            ],
        ))
      ],
    );
  }
}