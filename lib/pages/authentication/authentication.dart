import 'package:admindashboard/constants/style.dart';
import 'package:admindashboard/pages/register/register.dart';
import 'package:admindashboard/widgets/custom_text.dart';
import 'package:admindashboard/widgets/message_box.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../routing/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool notVisiblePassword = false;
  bool isChecked = false;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    _loadRememberMe();
    super.initState();
  }

    @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

    // Load the remember me state and email
  void _loadRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isChecked = prefs.getBool('rememberMe') ?? false;
      if (isChecked) {
        _email.text = prefs.getString('email') ?? '';
      }
    });
  }

  // Save the remember me state and email
  void _saveRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', isChecked);
    if (isChecked) {
      await prefs.setString('email', _email.text);
    } else {
      await prefs.remove('email');
    }
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
                  const Spacer(), // Espacio antes de la imagen
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Image.asset(
                      'assets/icons/gosoftware.png',
                      height: 200,
                      width: 200 ,
                    ),
                  ),
                  const Spacer(), // Espacio después de la imagen
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  Text(
                    'Login',
                    style: GoogleFonts.roboto(
                        fontSize: 30, fontWeight: FontWeight.bold),
                  )
                ],
              ),
              Row(
                children: [
                  CustomText(
                      text: "Welcome back, you've been missed!",
                      color: lightGrey)
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
                obscureText: !notVisiblePassword, // Toggles between show/hide password
                enableSuggestions: false,
                autocorrect: false,
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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: isChecked,
                        onChanged: (value) {
                          setState(() {
                            isChecked = value!;
                          });
                        },
                      ),
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
                onTap: () async {
                  final email = _email.text;
                  final password = _password.text;
                  try {
                    final UserCredential userCredential =
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                            email: email, password: password);
                    _saveRememberMe(); // Save remember me state
                    Get.offAllNamed(rootRoute);
                  } on FirebaseAuthException catch (e) {
                    print(e.code);
                    if (e.code == "user-not-found") {
                      // Handle case when email is not registered
                      showCustomAlert(context, "User not found. Please register.");
                    } else if (e.code == "wrong-password") {
                      // Handle incorrect password
                      showCustomAlert(context, "Incorrect password. Please try again.");
                    } else if (e.code == "invalid-email") {
                      // Handle invalid email format
                      showCustomAlert(context, "Invalid email format.");
                    } else if (e.code == "user-disabled") {
                      // Handle case where the account is disabled
                      showCustomAlert(context, "This account has been disabled.");
                    } else {
                      // Handle other errors
                      showCustomAlert(context, "Login failed. Please try again.");
                    }
                  }
                  //Get.offAllNamed(rootRoute);
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: active, borderRadius: BorderRadius.circular(20)),
                  alignment: Alignment.center,
                  width: double.maxFinite,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: const CustomText(
                    text: "Login",
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          const RegisterPage(), // Directly pushing the RegisterPage widget
                    ),
                  );
                },
                child: const Text("Not register yet? Register here"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
