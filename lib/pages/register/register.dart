import 'package:admindashboard/constants/style.dart';
import 'package:admindashboard/pages/authentication/authentication.dart';
import 'package:admindashboard/pages/verification/verification_page.dart';
import 'package:admindashboard/widgets/custom_text.dart';
import 'package:admindashboard/widgets/message_box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _repeated_password;
  late final TextEditingController _name;
  late final TextEditingController _surname;
  late final TextEditingController _phone;
  bool notVisiblePassword = true;
  bool notVisibleRepeatPassword = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _passwordsMatch = true;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    _repeated_password = TextEditingController();
    _name = TextEditingController();
    _surname = TextEditingController();
    _phone = TextEditingController();
    super.initState();
  }

  // Función para generar el siguiente código de usuario
  Future<String> getNextUserCode() async {
    final usersCollection = FirebaseFirestore.instance.collection('Users');
    final querySnapshot = await usersCollection
        .orderBy('Codigo', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return 'usr001';
    } else {
      final lastCode = querySnapshot.docs.first['Codigo'] as String;
      final lastNumber = int.parse(lastCode.substring(3));
      return 'usr${(lastNumber + 1).toString().padLeft(3, '0')}';
    }
  }

  // Función para guardar el usuario en Firestore
Future<void> saveUserToFirestore(User user) async {
    final userCode = await getNextUserCode();
    await FirebaseFirestore.instance.collection('Users').doc(user.uid).set({
      'email': user.email,
      'createdAt': FieldValue.serverTimestamp(),
      'Codigo': userCode,
      'Nombre': _name.text,
      'Apellidos': _surname.text,
      'Telefono': _phone.text,
    });
  }

  //Verifica que el email no este en uso
  Future<bool> isEmailAlreadyInUse(String email) async {
    final result = await FirebaseFirestore.instance
        .collection('Users')
        .where('email', isEqualTo: email)
        .get();
    return result.docs.isNotEmpty;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    bool isPassword = false,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool isRepeatedPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? (labelText == 'Password' ? notVisiblePassword : notVisibleRepeatPassword) : false,
      enableSuggestions: !isPassword,
      autocorrect: !isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: (isRepeatedPassword && !_passwordsMatch) ? Colors.red : Colors.grey,
            width: 2.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: (isRepeatedPassword && !_passwordsMatch) ? Colors.red : Colors.grey,
            width: 2.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: (isRepeatedPassword && !_passwordsMatch) ? Colors.red : Colors.blue,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2.0,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2.0,
          ),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  (labelText == 'Password' ? notVisiblePassword : notVisibleRepeatPassword)
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    if (labelText == 'Password') {
                      notVisiblePassword = !notVisiblePassword;
                    } else if (labelText == 'Repita su Password') {
                      notVisibleRepeatPassword = !notVisibleRepeatPassword;
                    }
                  });
                },
              )
            : null,
      ),
      validator: (value) {
        if (validator != null) {
          String? validationResult = validator(value);
          if (validationResult != null) {
            return validationResult;
          }
        }
        if (isRepeatedPassword && value != _password.text) {
          setState(() {
            _passwordsMatch = false;
          });
          return 'Las contraseñas no coinciden';
        }
        return null;
      },
      onChanged: (value) {
        if (isRepeatedPassword || labelText == 'Password') {
          setState(() {
            _passwordsMatch = _repeated_password.text == _password.text;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Bordes redondeados
          ),
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return Column(
                      mainAxisSize: MainAxisSize.min, // Ajusta la altura del Card al contenido
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
                        const SizedBox(height: 30),
                        Text(
                          'Sign Up',
                          style: GoogleFonts.roboto(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        CustomText(
                          text: "Sign up with your email!",
                          color: lightGrey,
                        ),
                        const SizedBox(height: 15),
                        constraints.maxWidth > 600
                            ? Column(
                                children: [
                                  _buildRowFields(
                                    _name, _surname, 'Nombre', 'Apellido'),
                                  const SizedBox(height: 15),
                                  _buildRowFields(
                                    _email, _phone, 'Email', 'Teléfono',
                                    isPhoneOptional: true),
                                  const SizedBox(height: 15),
                                  _buildRowFields(
                                    _password, _repeated_password, 'Password', 'Repita su Password',
                                    isSecondFieldPassword: true),
                                ],
                              )
                            : Column(
                                children: [
                                  _buildTextField(
                                    controller: _name,
                                    labelText: 'Nombre',
                                    hintText: 'Ingrese su nombre',
                                    validator: (value) => value!.isEmpty ? 'El campo nombre es obligatorio' : null,
                                  ),
                                  const SizedBox(height: 15),
                                  _buildTextField(
                                    controller: _surname,
                                    labelText: 'Apellidos',
                                    hintText: 'Ingrese sus apellidos',
                                    validator: (value) => value!.isEmpty ? 'El campo apellidos es obligatorio' : null,
                                  ),
                                  const SizedBox(height: 15),
                                  _buildTextField(
                                    controller: _email,
                                    labelText: 'Email',
                                    hintText: 'abc@domain.com',
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) => value!.isEmpty ? 'Ingrese su email' : null,
                                  ),
                                  const SizedBox(height: 15),
                                  _buildTextField(
                                    controller: _phone,
                                    labelText: 'Teléfono',
                                    hintText: 'Ingrese su número de teléfono (opcional)',
                                    keyboardType: TextInputType.phone,
                                  ),
                                  const SizedBox(height: 15),
                                  _buildTextField(
                                    controller: _password,
                                    labelText: 'Password',
                                    hintText: 'Al menos 8 caracteres',
                                    isPassword: true,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Ingrese su password';
                                      }
                                      if (value.length < 8) {
                                        return 'Password debe tener al menos 8 caracteres';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 15),
                                  _buildTextField(
                                    controller: _repeated_password,
                                    labelText: 'Repita su Password',
                                    hintText: 'Repita su password',
                                    isPassword: true,
                                    isRepeatedPassword: true,
                                    validator: (value) {
                                      if (value != _password.text) {
                                        return 'Las contraseñas no coinciden';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                        const SizedBox(height: 15),
                        InkWell(
                          onTap: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              if (_password.text != _repeated_password.text) {
                                setState(() {
                                  _passwordsMatch = false;
                                });
                                showCustomAlert(context, 'Las contraseñas no coinciden');
                                return;
                              }

                              final email = _email.text;
                              final password = _password.text;

                              bool emailExists = await isEmailAlreadyInUse(email);
                              if (emailExists) {
                                showCustomAlert(context, 'Email ya existe');
                                return;
                              }

                              try {
                                final UserCredential userCredential =
                                    await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                  email: email,
                                  password: password,
                                );

                                await saveUserToFirestore(userCredential.user!);

                                await userCredential.user?.sendEmailVerification();

                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => const VerifyEmailView(),
                                  ),
                                );
                              } on FirebaseAuthException catch (e) {
                                if (e.code == 'weak-password') {
                                  showCustomAlert(context, 'Password Debil');
                                } else if (e.code == 'email-already-in-use') {
                                  showCustomAlert(context, 'Usuario ya existe');
                                } else {
                                  showCustomAlert(context, 'Email invalido');
                                }
                              } catch (e) {
                                showCustomAlert(context, 'Ocurrió un error. Intétalo de nuevo.');
                              }
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: active,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.center,
                            width: 200,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: const CustomText(
                              text: "Sign Up",
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const AuthenticationPage(),
                              ),
                            );
                          },
                          child: const Text("Ya tienes cuenta? Ingresa aqui"),
                        )
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRowFields(
    TextEditingController controller1,
    TextEditingController controller2,
    String label1,
    String label2, {
    bool isSecondFieldPassword = false,
    bool isPhoneOptional = false
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            controller: controller1,
            labelText: label1,
            isPassword: isSecondFieldPassword,
            hintText: isSecondFieldPassword ? 'Al menos 8 caracteres' : 'Ingrese su $label1',
            validator: (value) => value!.isEmpty ? 'Por favor ingrese su $label1' : null,
            keyboardType: label1 == 'Email' ? TextInputType.emailAddress :
                          label1 == 'Teléfono' ? TextInputType.phone : null,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildTextField(
            controller: controller2,
            labelText: label2,
            hintText: isSecondFieldPassword ? 'Al menos 8 caracteres' : 'Ingrese su $label2${isPhoneOptional ? ' (opcional)' : ''}',
            isPassword: isSecondFieldPassword,
            validator: (value) {
              if (isPhoneOptional && label2 == 'Teléfono') {
                return null; // No validation for optional phone field
              }
              if (value!.isEmpty) {
                return 'Por favor ingrese su $label2';
              }
              if (isSecondFieldPassword && value.length < 8) {
                return 'Password debe tener al menos 8 caracteres';
              }
              return null;
            },
            keyboardType: label2 == 'Teléfono' ? TextInputType.phone : null,
          ),
        ),
      ],
    );
  }
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _repeated_password.dispose();
    _name.dispose();
    _surname.dispose();
    _phone.dispose();
    super.dispose();
  }
}