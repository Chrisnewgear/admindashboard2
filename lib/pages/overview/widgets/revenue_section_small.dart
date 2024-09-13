import 'package:admindashboard/constants/style.dart';
import 'package:admindashboard/pages/overview/widgets/revenue_info.dart';
import 'package:admindashboard/widgets/bar_charts.dart';
import 'package:admindashboard/widgets/custom_text.dart';
import 'package:flutter/material.dart';

class RevenueSectionSmall extends StatelessWidget {
  const RevenueSectionSmall({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 6),
            color: lightGrey.withOpacity(.1),
            blurRadius: 12,
          ),
        ],
        border: Border.all(color: lightGrey, width: .5),
      ), // Added missing closing bracket for BoxDecoration
      child: Column(
        children: [
          Container(
            height: 260,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomText(
                  text: "Revenue Chart",
                  size: 20,
                  weight: FontWeight.bold,
                  color: lightGrey,
                ),
                const SizedBox(
                  width: 600,
                  height: 200,
                  child: SimpleBarChart(),
                ),
              ],
            ),
          ),
          Container(
            height: 1,
            width: 120,
            color: lightGrey,
          ),
          const SizedBox(
            height: 260,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    RevenueInfo(
                      title: "Today's revenue",
                      amount: "23",
                    ),
                    RevenueInfo(
                      title: "Last 7 days",
                      amount: "150",
                    ),
                  ],
                ),
                Row(
                  children: [
                    RevenueInfo(
                      title: "Last 30 days",
                      amount: "1,203",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
