import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:admindashboard/widgets/custom_text.dart';
import 'package:admindashboard/constants/style.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _resetPassword() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent. Check your inbox.')),
      );
      Navigator.of(context).pop(); // Return to the login page
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred. Please try again.';
      print(e.code);
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this email address.';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
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
              const CustomText(
                text: 'Enter your email to reset your password',
                size: 18,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: active,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _isLoading ? null : _resetPassword,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const CustomText(
                          text: 'Reset Password',
                          color: Colors.white,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}