import 'package:admindashboard/constants/style.dart';
import 'package:admindashboard/pages/authentication/authentication.dart';
import 'package:admindashboard/widgets/custom_text.dart';
import 'package:admindashboard/widgets/message_box.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../routing/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>{
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _repeated_password;
  bool notVisiblePassword = false;
  bool notVisibleRepeatPassword = false;
  //final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    _repeated_password = TextEditingController();
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
                  Text('Sign Up', style: GoogleFonts.roboto(
                    fontSize: 30, fontWeight: FontWeight.bold
                  ),)
                ],
              ),

              Row(
                children: [
                  CustomText(text: "Sign up with your email!",
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

              TextFormField(
                controller: _password,
                obscureText: !notVisiblePassword, // Toggles between show/hide password
                enableSuggestions: false,
                autocorrect: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'At least 8 characters',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      notVisiblePassword == false ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        // Toggle visibility
                        notVisiblePassword = !notVisiblePassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: _repeated_password,
                obscureText: !notVisibleRepeatPassword,
                enableSuggestions: false,
                autocorrect: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _password.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Repeat Password',
                  hintText: 'Repeat your password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      notVisibleRepeatPassword == false ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        // Toggle visibility
                        notVisibleRepeatPassword = !notVisibleRepeatPassword;
                      });
                    },
                  ),
                  ),
                ),

              const SizedBox(
                height: 15,
              ),

              InkWell(
                onTap: () async{
                  final email = _email.text;
                  final password = _password.text;
                  // if (_formKey.currentState!.validate()) {
                    try{
                      final UserCredential userCredential =
                      await FirebaseAuth.instance.createUserWithEmailAndPassword(
                          email: email, password: password);
                        Get.offAllNamed(rootRoute);
                    } on FirebaseAuthException catch(e){
                      //print(e.code);
                      if (e.code == 'weak-password') {
                        // Handle errors here, e.g., show an error message to the user
                        showCustomAlert(context, 'Weak Password');
                      } else if (e.code == 'email-already-in-use') {
                        showCustomAlert(context,'User already exist');
                      } else {
                        showCustomAlert(context,'Invalid e-mail entered');
                      }
                      //print("I'm here");
                    }
                  // }else{
                  //   print("I'm outside");
                  // }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: active,
                    borderRadius: BorderRadius.circular(20)),
                    alignment: Alignment.center,
                    width: double.maxFinite,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: const CustomText(
                      text: "Sign Up",
                      color: Colors.white,
                    ),
                ),
              ),
              const SizedBox(height: 15,),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          const AuthenticationPage(), // Directly pushing the RegisterPage widget
                    ),
                  );
                },
                child: const Text("Already have an account? Login here"),
              )
            ],
          ),
        ),
      ),
    );
  }

    @override
  void dispose() {
    _password.dispose();
    _repeated_password.dispose();
    super.dispose();
  }
}