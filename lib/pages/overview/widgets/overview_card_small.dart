import 'package:admindashboard/pages/overview/widgets/info_card_small.dart';
import 'package:flutter/material.dart';

class OverViewCardSmallScreen extends StatelessWidget {
  const OverViewCardSmallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return SizedBox(
      height: 350,
      child: Column(children: [
        InfoCardSmall(
          title: "Visitas",
          value: "8",
          onTap: () {},
          isActive: true,
        ),
        SizedBox(
          height: width / 1024
        ),

        InfoCardSmall(
          title: "Clientes",
          value: "17",
          onTap: () {},
          isActive: true,
        ),
        SizedBox(
          height: width / 1024
        ),

        InfoCardSmall(
          title: "Ventas",
          value: "3",
          onTap: () {},
          isActive: true,
        ),
        SizedBox(
          height: width / 1024
        ),

        InfoCardSmall(
          title: "Scheduled deliveries",
          value: "32",
          onTap: () {},
          isActive: true,
        ),
        SizedBox(
          height: width / 1024
        ),
      ]),
    );
  }
}
