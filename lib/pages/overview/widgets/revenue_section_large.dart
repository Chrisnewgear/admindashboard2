import 'package:admindashboard/constants/style.dart';
import 'package:admindashboard/pages/overview/widgets/revenue_info.dart';
import 'package:admindashboard/widgets/bar_charts.dart';
import 'package:admindashboard/widgets/custom_text.dart';
import 'package:flutter/material.dart';

class RevenueSectionLarge extends StatelessWidget {
  const RevenueSectionLarge({super.key});

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
            blurRadius: 12
          ),
        ],
        border: Border.all(color: lightGrey, width: .5)),
        child: Row(
          children: [
            Expanded(child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomText(
                  text: "Revenue Chart",
                  size: 20,
                  weight: FontWeight.bold,
                  color: lightGrey,),

                  const SizedBox(
                    width: 600,
                    height: 200,
                    child: SimpleBarChart(),
                  )
              ]
            )),
            Container(
              width: 1,
              height: 120,
              color: lightGrey,
            ),

            const Expanded(
              child: Column(
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
                  SizedBox(height: 30,),

                  Row(
                    children: [
                      RevenueInfo(
                        title: "Last 30 days",
                        amount: "1,203",
                      ),
                      RevenueInfo(
                        title: "Last 12 months",
                        amount: "3,230",
                      ),
                    ],
                  ),
                ],
              ))
          ]
        ),
    );
  }
}