import 'package:admindashboard/pages/overview/widgets/info_card_small.dart';
import 'package:flutter/material.dart';

class OverViewCardSmallScreen extends StatelessWidget {
  const OverViewCardSmallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Container(
      height: 400,
      child: Column(children: [
        InfoCardSmall(
          title: "Rides in progress",
          value: "7",
          onTap: () {},
          isActive: true,
        ),
        SizedBox(
          height: width / 64
        ),

        InfoCardSmall(
          title: "Packages delivered",
          value: "17",
          onTap: () {},
          isActive: true,
        ),
        SizedBox(
          height: width / 64
        ),

        InfoCardSmall(
          title: "Cancelled delivery",
          value: "3",
          onTap: () {},
          isActive: true,
        ),
        SizedBox(
          height: width / 64
        ),

        InfoCardSmall(
          title: "Scheduled deliveries",
          value: "32",
          onTap: () {},
          isActive: true,
        ),
        SizedBox(
          height: width / 64
        ),
      ]),
    );
  }
}
