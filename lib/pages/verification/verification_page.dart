import 'package:admindashboard/layout.dart';
import 'package:admindashboard/widgets/message_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      showCustomAlert(context, 'Debes verificar tu email para poder iniciar sesión.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verificar tu Email'),),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isEmailVerified)
                const Text('Por favor verifica tu email, revisa la bandeja de entrada o de spam de tu correo y da clic en el enlace de verificación.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: verifyEmail,
                child: const Text('Ya verifiqué el email'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
