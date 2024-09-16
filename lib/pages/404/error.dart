import 'package:admindashboard/widgets/custom_text.dart';
import 'package:flutter/material.dart';

class PageNotFound extends StatelessWidget {
  const PageNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/images/error.jpg", width: 350,),
          const SizedBox(height: 10,),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomText(text: "Page not found", size: 24, weight: FontWeight.bold,),
            ],
          )
        ],
      ),
    );
  }
}