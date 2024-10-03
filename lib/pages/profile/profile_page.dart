import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:admindashboard/constants/style.dart';
import 'package:admindashboard/widgets/custom_text.dart';

class ProfileWidget extends StatelessWidget {
  const ProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('Users').doc(user?.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('No user data found'));
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;

        return SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Perfil de Usuario',
                  style: GoogleFonts.roboto(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _buildProfileItem('Código', userData['Codigo'] ?? 'N/A'),
                _buildProfileItem('Nombre', userData['Nombre'] ?? 'N/A'),
                _buildProfileItem('Apellidos', userData['Apellidos'] ?? 'N/A'),
                _buildProfileItem('Email', userData['email'] ?? 'N/A'),
                _buildProfileItem('Teléfono', userData['Telefono'] ?? 'N/A'),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: active,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    ),
                    onPressed: () {
                      // Aquí puedes agregar la lógica para editar el perfil
                    },
                    child: const CustomText(
                      text: "Editar Perfil",
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold, color: lightGrey),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.roboto(fontSize: 18),
          ),
          const Divider(),
        ],
      ),
    );
  }
}