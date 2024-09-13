import 'package:admindashboard/constants/style.dart';
import 'package:flutter/material.dart';

class RevenueInfo extends StatelessWidget {
  final String title;
  final String amount;
  const RevenueInfo({super.key, required this.title, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
        children: [
          TextSpan(
            text: "$title\n\n",
            style: TextStyle(
              color: lightGrey, fontSize: 16
            ),
          ),
          TextSpan(
            text: "\$ $amount\n\n",
            style: const TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold
            ),
          )
        ]
      )),
    );
  }
}