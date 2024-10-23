// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:admindashboard/widgets/custom_text.dart';

// class ForgotPasswordPage extends StatefulWidget {
//   const ForgotPasswordPage({super.key});

//   @override
//   _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
// }

// class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
//   final TextEditingController _emailController = TextEditingController();
//   bool _isLoading = false;

//   Future<void> _resetPassword() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       await FirebaseAuth.instance.sendPasswordResetEmail(
//         email: _emailController.text.trim(),
//       );
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text('Password reset email sent. Check your inbox.')),
//       );
//       Navigator.of(context).pop(); // Return to the login page
//     } on FirebaseAuthException catch (e) {
//       String errorMessage = 'An error occurred. Please try again.';
//       print(e.code);
//       if (e.code == 'user-not-found') {
//         errorMessage = 'No user found with this email address.';
//       }
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(errorMessage)),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Cambio de Contraseña'),
//       ),
//       body: Center(
//         child: Card(
//           elevation: 4,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Container(
//             constraints: const BoxConstraints(maxWidth: 400),
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Row(
//                   children: [
//                     const Spacer(),
//                     Padding(
//                       padding: const EdgeInsets.only(right: 12),
//                       child: Image.asset(
//                         'assets/icons/goSoftwareSolutions-01.png',
//                         height: 200,
//                         width: 200,
//                       ),
//                     ),
//                     const Spacer(),
//                   ],
//                 ),
//                 const SizedBox(
//                   height: 30,
//                 ),
//                 const Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Flexible(
//                       child: Text(
//                         'Ingrese tu mail para cambiar tu contraseña',
//                         style: TextStyle(
//                           fontSize: 18,
//                         ),
//                         textAlign: TextAlign.center,
//                         maxLines: 2,
//                         softWrap: true,
//                         overflow: TextOverflow.visible,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//                 TextField(
//                   controller: _emailController,
//                   decoration: InputDecoration(
//                     labelText: 'Email',
//                     hintText: 'Ingrese su email',
//                     hintStyle: TextStyle(
//                       color: Colors.grey.withOpacity(
//                           0.5), // Aquí atenuamos el color del hintText
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                   ),
//                   keyboardType: TextInputType.emailAddress,
//                 ),
//                 const SizedBox(height: 20),
//                 SizedBox(
//                   width: double.infinity,
//                   child: InkWell(
//                     onTap: _isLoading ? null : _resetPassword,
//                     borderRadius: BorderRadius.circular(20),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: _isLoading
//                             ? Theme.of(context).primaryColor.withOpacity(0.6)
//                             : Theme.of(context).primaryColor,
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       alignment: Alignment.center,
//                       width: double.maxFinite,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       child: _isLoading
//                           ? const CircularProgressIndicator(color: Colors.white)
//                           : const CustomText(
//                               text: 'Cambiar Contraseña',
//                               color: Colors.white,
//                             ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:admindashboard/widgets/custom_text.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  bool _isLoading = false;

  // Nueva función para verificar la existencia del correo en Firebase
  Future<bool> _checkIfEmailExists(String email) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password:
            'any_password', // Puedes usar una contraseña temporal para la verificación
      );
      // Si llegamos hasta aquí sin excepción, el correo ya existe
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // El correo ya está en uso
        return true;
      } else if (e.code == 'invalid-email') {
        // Correo inválido
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El formato de correo no es válido')),
        );
      } else {
        // Otro error de Firebase
        print('Error de Firebase: ${e.message}');
      }
      return false;
    }
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final emailExists =
          await _checkIfEmailExists(_emailController.text.trim());

      if (!emailExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No existe un usuario con ese correo electrónico.'),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      try {
        // Intentamos enviar el email de restablecimiento
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: _emailController.text.trim(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Correo para restablecer contraseña enviado. Verifica tu bandeja de entrada.')),
        );
        Navigator.of(context).pop(); // Return to the login page
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Ocurrió un error. Intente nuevamente.';
        if (e.code == 'user-not-found') {
          errorMessage = 'No existe un usuario con ese correo electrónico.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'El formato de correo no es válido.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cambio de Contraseña'),
      ),
      body: Center(
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey, // Add form key here
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Image.asset(
                          'assets/icons/goSoftwareSolutions-01.png',
                          height: 200,
                          width: 200,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          'Ingrese tu mail para cambiar tu contraseña',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Ingrese su email',
                      hintStyle: TextStyle(
                        color: Colors.grey.withOpacity(0.5),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Debe ingresar un email válido';
                      }
                      // Validación de formato de email
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      if (!emailRegex.hasMatch(value)) {
                        return 'Debe ingresar un email válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: InkWell(
                      onTap: _isLoading ? null : _resetPassword,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _isLoading
                              ? Theme.of(context).primaryColor.withOpacity(0.6)
                              : Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        width: double.maxFinite,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const CustomText(
                                text: 'Cambiar Contraseña',
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
