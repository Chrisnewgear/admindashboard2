import 'package:admindashboard/constants/style.dart';
import 'package:admindashboard/widgets/custom_text.dart';
import 'package:admindashboard/widgets/message_box.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../routing/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}



class _AuthenticationPageState extends State<AuthenticationPage>{
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

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
                    child: Image.asset('assets/icons/gosoftware.jpeg', height: 50, width: 50,),),
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
              controller: _email,
              enableSuggestions: false,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
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
                controller: _password,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
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
                      Checkbox(value: false, onChanged: (value){}),
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
                onTap: () async{
                  //final email = _email.text;
                  //final password = _password.text;
                  // try{
                  //   FirebaseAuth.instance
                  //     .signInWithEmailAndPassword(email: email, password: password);
                  // } on FirebaseAuthException catch(e){
                  //   print(e.code);
                  //   if(e.code == "invalid-credential"){
                  //     showCustomAlert(context, "User not found");
                  //   }else if(e.code == "wrong-password"){
                  //     //showCustomAlert(context, "Wrong password");
                  //   }
                  // }
                    Get.offAllNamed(rootRoute);
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