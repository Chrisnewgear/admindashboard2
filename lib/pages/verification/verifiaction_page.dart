import 'package:admindashboard/layout.dart';
import 'package:admindashboard/pages/overview/overview.dart';
import 'package:admindashboard/widgets/message_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  _VerifyEmailViewState createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  bool isEmailVerified = false;

  @override
  void initState() {
    super.initState();
    // Al cargar la vista, comprueba si el correo ya ha sido verificado
    checkEmailVerified();
  }

    Future<void> checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser?.reload(); // Recarga el estado del usuario
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    });
  }
  void verifyEmail() async {
    await checkEmailVerified();
    if (isEmailVerified) {
      // Navega al dashboard si el correo ya está verificado
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => SiteLayout()),
      );
    }else{
      showCustomAlert(context, 'You have to verify your email first');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isEmailVerified)
              const Text('Please verify your email address'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: verifyEmail,
              child: const Text('I have verified my email'),
            ),
          ],
        ),
      ),
    );
  }
}
