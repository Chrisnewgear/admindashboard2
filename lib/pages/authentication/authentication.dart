import 'package:admindashboard/constants/style.dart';
import 'package:admindashboard/pages/forgot_password/forgot_password.dart';
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
class _AuthenticationPageState extends State<AuthenticationPage> with SingleTickerProviderStateMixin {
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool notVisiblePassword = false;
  bool isChecked = false;
  bool isPasswordIncorrect = false;
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;

@override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    _loadRememberMe();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.1, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticIn,
    ));
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _animationController.dispose();
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
  void _shakePassword() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
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
                      'assets/icons/goSoftwareSolutions-01.png',
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
                      text: "Bienvenido, te hemos extrañado!",
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

              SlideTransition(
                position: _offsetAnimation,
                child: TextFormField(
                  controller: _password,
                  obscureText: !notVisiblePassword,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Al menos 8 caracteres',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: isPasswordIncorrect ? Colors.red : Colors.grey,
                        width: 2.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: isPasswordIncorrect ? Colors.red : Colors.grey,
                        width: 2.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: isPasswordIncorrect ? Colors.red : active,
                        width: 2.0,
                      ),
                    ),
                    labelStyle: TextStyle(
                      color: isPasswordIncorrect ? Colors.red : Colors.grey,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        notVisiblePassword == false ? Icons.visibility_off : Icons.visibility,
                        color: isPasswordIncorrect ? Colors.red : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          notVisiblePassword = !notVisiblePassword;
                        });
                      },
                    ),
                    errorText: isPasswordIncorrect ? 'Password incorrecto' : null,
                    errorStyle: const TextStyle(color: Colors.red),
                  ),
                  onChanged: (value) {
                    if (isPasswordIncorrect) {
                      setState(() {
                        isPasswordIncorrect = false;
                      });
                    }
                  },
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
                      const CustomText(text: 'Recuérdame'),
                    ],
                  ),
                  TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          const ForgotPasswordPage(),
                    ),
                  );
                },
                child: const Text("Olvidaste tu contraseña?"),
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
                    //print("Error Code: ${e.code}");
                    //print("Error Message: ${e.message}");

                    if (e.code == "user-not-found") {
                      showCustomAlert(context, "User not found. Please register.");
                    } else if (e.message == "The supplied auth credential is incorrect, malformed or has expired.") {
                      setState(() {
                        isPasswordIncorrect = true;
                      });
                      _shakePassword();
                    }else if(e.message == "Access to this account has been temporarily disabled due to many failed login attempts. You can immediately restore it by resetting your password or you can try again later."){
                      showCustomAlert(context, "Access to this account has been temporarily disabled due to many failed login attempts. You can immediately restore it by resetting your password or you can try again later.");
                    } else if (e.message == "invalid-email") {
                      showCustomAlert(context, "Invalid email format.");
                    } else if (e.code == "user-disabled") {
                      showCustomAlert(context, "This account has been disabled.");
                    } else {
                      showCustomAlert(context, "Login failed. Please try again.");
                    }
                  }
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
                child: const Text("No tienes una cuenta? Registrate aquí"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
