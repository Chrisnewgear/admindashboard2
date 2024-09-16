import 'package:admindashboard/constants/style.dart';
import 'package:admindashboard/pages/overview/overview.dart';
import 'package:admindashboard/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../layout.dart';

class AuthenticationPage extends StatelessWidget {
  const AuthenticationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Padding(padding: const EdgeInsets.only(right: 12),
                    child: Image.asset('assets/icons/Logo-Techmall.webp'),),
                    Expanded(child: Container())
                ],
              ),
              const SizedBox(
                height: 30,
              ),

              Row(
                children: [
                  Text('Login', style: GoogleFonts.roboto(
                    fontSize: 30, fontWeight: FontWeight.bold
                  ),)
                ],
              ),

              Row(
                children: [
                  CustomText(text: "Welcome back, you've been missed!", 
                    color: lightGrey
                  )
                ],
              ),

              const SizedBox(
                height: 15,
              ),

              TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'abc@domain.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20))),
              ),

              const SizedBox(
                height: 15,
              ),

              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: '123',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20))),
              ),

              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(value: true, onChanged: (value){}),
                      const CustomText(text: 'Remember Me'),
                    ],
                  ),

                  CustomText(
                    text: 'Forgot Password?',
                    color: active,
                  )
                ],
              ),

              const SizedBox(
                height: 15,
              ),

              InkWell(
                onTap: () {
                  Get.offAll(() => SiteLayout());
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: active,
                    borderRadius: BorderRadius.circular(20)),
                    alignment: Alignment.center,
                    width: double.maxFinite,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: const CustomText(
                      text: "Login",
                      color: Colors.white,
                    ),
                ),
              ),

              const SizedBox(height: 15,),

              RichText(text: TextSpan(children: [
                const TextSpan(text: "Don't have admin credentials? "),
                TextSpan(text: "Request Credentials!", style: TextStyle(color: active)),
              ]))
            ],
          ),
        ),
      ),
    );
  }
}