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
  bool notVisiblePassword = false;
  bool notVisibleRepeatPassword = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? !notVisiblePassword : false,
      enableSuggestions: !isPassword,
      autocorrect: !isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20)
        ),
        suffixIcon: isPassword ? IconButton(
          icon: Icon(
            notVisiblePassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              notVisiblePassword = !notVisiblePassword;
            });
          },
        ) : null,
      ),
      validator: validator,
    );
  }
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Image.asset('assets/icons/gosoftware.png', height: 200, width: 200,),
                          ),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Text('Sign Up', style: GoogleFonts.roboto(fontSize: 30, fontWeight: FontWeight.bold)),
                      CustomText(text: "Sign up with your email!", color: lightGrey),
                      const SizedBox(height: 15),
                      // Responsive layout for form fields
                      constraints.maxWidth > 600
                          ? Column(
                              children: [
                                _buildRowFields(_name, _surname, 'Name', 'Surname'),
                                const SizedBox(height: 15),
                                _buildRowFields(_email, _phone, 'Email', 'Phone'),
                                const SizedBox(height: 15),
                                _buildRowFields(_password, _repeated_password, 'Password', 'Repeat Password', isSecondFieldPassword: true),
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
                                  labelText: 'Phone',
                                  hintText: 'Ingrese su número de teléfono',
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
                                  validator: (value) {
                                    if (value != _password.text) {
                                      return 'Passwords no coinciden';
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
                            final email = _email.text;
                            final password = _password.text;

                            // Check if email is already in use
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
                                showCustomAlert(context, 'Weak Password');
                              } else if (e.code == 'email-already-in-use') {
                                showCustomAlert(context, 'User already exists');
                              } else {
                                showCustomAlert(context, 'Invalid email entered');
                              }
                            } catch (e) {
                              showCustomAlert(context, 'An error occurred. Please try again.');
                            }
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: active,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          width: double.maxFinite,
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
                        child: const Text("Already have an account? Login here"),
                      )
                    ],
                  ),
                );
              },
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
    bool isSecondFieldPassword = false
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            controller: controller1,
            labelText: label1,
            hintText: 'Enter your $label1',
            validator: (value) => value!.isEmpty ? 'Please enter your $label1' : null,
            keyboardType: label1 == 'Email' ? TextInputType.emailAddress : 
                          label1 == 'Phone' ? TextInputType.phone : null,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildTextField(
            controller: controller2,
            labelText: label2,
            hintText: isSecondFieldPassword ? 'At least 8 characters' : 'Enter your $label2',
            isPassword: isSecondFieldPassword,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter your $label2';
              }
              if (isSecondFieldPassword && value.length < 8) {
                return 'Password must be at least 8 characters long';
              }
              return null;
            },
            keyboardType: label2 == 'Phone' ? TextInputType.phone : null,
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