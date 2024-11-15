import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  @override
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  final ValueNotifier<int> _selectedIndex =
      ValueNotifier<int>(0); // Notificador para evitar recargas completas
  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<bool> isEditing = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isPasswordEditMode = ValueNotifier(false);
  final ValueNotifier<bool> _obscurePasswordNotifier =
      ValueNotifier<bool>(true);

  late TextEditingController nameController;
  late TextEditingController apellidoController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;
  late TextEditingController phoneController;
  late TextEditingController locationController;
  //bool _obscurePassword = true;
  //bool _isEditMode = false;
  //bool _isPasswordEditMode = false;
  //int _selectedIndex = 0; // Index to track the selected tab
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    apellidoController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    phoneController = TextEditingController();
    locationController = TextEditingController();
  }

  @override
  void dispose() {
    _selectedIndex.dispose();
    nameController.dispose();
    apellidoController.dispose();
    emailController.dispose();
    passwordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    locationController.dispose();
    isPasswordEditMode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1024;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(user?.uid)
          .snapshots(),
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

        // Update controllers with user data
        nameController.text = userData['Nombre'] ?? '';
        apellidoController.text = userData['Apellidos'] ?? '';
        emailController.text = userData['email'] ?? '';
        phoneController.text = userData['Telefono'] ?? '';

        return Scaffold(
          body: isDesktop
              ? _buildDesktopLayout(context)
              : _buildMobileLayout(context),
        );
      },
    );
  }

  // Widget _buildDesktopLayout(BuildContext context) {
  //   return SingleChildScrollView(
  //     child: Padding(
  //       padding: const EdgeInsets.all(32.0),
  //       child: Row(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           // Left sidebar with navigation
  //           Card(
  //             elevation: 2,
  //             child: Container(
  //               width: 250,
  //               padding: const EdgeInsets.all(24),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   // Profile photo section
  //                   Center(
  //                     child: Stack(
  //                       children: [
  //                         Container(
  //                           width: 120,
  //                           height: 120,
  //                           decoration: BoxDecoration(
  //                             color: Colors.grey[200],
  //                             shape: BoxShape.circle,
  //                           ),
  //                           child: const Icon(
  //                             Icons.photo_library_outlined,
  //                             size: 50,
  //                             color: Colors.grey,
  //                           ),
  //                         ),
  //                         Positioned(
  //                           right: 0,
  //                           bottom: 0,
  //                           child: Container(
  //                             padding: const EdgeInsets.all(8),
  //                             decoration: const BoxDecoration(
  //                               color: Colors.indigo,
  //                               shape: BoxShape.circle,
  //                             ),
  //                             child: const Icon(
  //                               Icons.camera_alt,
  //                               size: 20,
  //                               color: Colors.white,
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                   const SizedBox(height: 24),
  //                   _buildNavItem('Edit Profile', isSelected: _selectedIndex == 0),
  //                   _buildNavItem('Preference', isSelected: _selectedIndex == 1),
  //                   _buildNavItem('Security', isSelected: _selectedIndex == 2),
  //                   _buildNavItem('Notifications', isSelected: _selectedIndex == 3),
  //                   //_buildNavItem('Connected Accounts'),
  //                 ],
  //               ),
  //             ),
  //           ),
  //           const SizedBox(width: 24),
  //           // Main content area
  //           Expanded(
  //             child: Card(
  //               elevation: 2,
  //               child: Container(
  //                 padding: const EdgeInsets.all(32),
  //                 child: _selectedIndex == 0
  //                     ? _buildProfileEditSection()
  //                     : _selectedIndex == 2
  //                         ? _buildPasswordChangeSection()
  //                         : const SizedBox.shrink(),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildDesktopLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barra lateral izquierda con navegación
            Card(
              elevation: 2,
              child: Container(
                width: 250,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sección de foto de perfil
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.photo_library_outlined,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.indigo,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildNavItem('Edit Profile'),
                    _buildNavItem('Preference'),
                    _buildNavItem('Security'),
                    _buildNavItem('Notifications'),
                    //_buildNavItem('Connected Accounts'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 24),
            // Área de contenido principal
            Expanded(
              child: Card(
                elevation: 2,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  child: ValueListenableBuilder<int>(
                    valueListenable: _selectedIndex,
                    builder: (context, selectedIndex, _) {
                      // Renderizamos la sección según el índice seleccionado
                      if (selectedIndex == 0) {
                        return _buildProfileEditSection();
                      } else if (selectedIndex == 2) {
                        return _buildPasswordChangeSection();
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildMobileLayout(BuildContext context) {
  //   return SingleChildScrollView(
  //     child: Container(
  //       constraints: BoxConstraints(
  //         maxWidth: MediaQuery.of(context).size.width * 0.95,
  //       ),
  //       margin: const EdgeInsets.symmetric(
  //         vertical: 16,
  //         horizontal: 12,
  //       ),
  //       padding: const EdgeInsets.all(16),
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(16),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.grey.withOpacity(0.1),
  //             spreadRadius: 1,
  //             blurRadius: 10,
  //           ),
  //         ],
  //       ),
  //       child: Form(
  //         key: _formKey,
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             SingleChildScrollView(
  //               scrollDirection: Axis.horizontal,
  //               child: Row(
  //                 children: [
  //                   _buildTab('Edit Profile', isSelected: _selectedIndex == 0, index: 0),
  //                   _buildTab('Preference', isSelected: _selectedIndex == 1, index: 1),
  //                   _buildTab('Security', isSelected: _selectedIndex == 2, index: 2),
  //                 ],
  //               ),
  //             ),
  //             const SizedBox(height: 24),
  //             if (_selectedIndex == 0)
  //               _buildProfileEditSection()
  //             else if (_selectedIndex == 2)
  //               _buildPasswordChangeSection()
  //             else
  //               const SizedBox.shrink(),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.95,
        ),
        margin: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTab('Edit Profile', 0),
                    _buildTab('Preference', 1),
                    _buildTab('Security', 2),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ValueListenableBuilder<int>(
                valueListenable: _selectedIndex,
                builder: (context, index, _) {
                  if (index == 0) {
                    return _buildProfileEditSection();
                  } else if (index == 2) {
                    return _buildPasswordChangeSection();
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String text) {
    return GestureDetector(
      onTap: () {
        // Actualizamos el valor de `_selectedIndex` directamente para evitar el uso de `setState`
        switch (text) {
          case 'Edit Profile':
            _selectedIndex.value = 0;
            break;
          case 'Preference':
            _selectedIndex.value = 1;
            break;
          case 'Security':
            _selectedIndex.value = 2;
            break;
          case 'Notifications':
            _selectedIndex.value = 3;
            break;
        }
      },
      child: ValueListenableBuilder<int>(
        valueListenable: _selectedIndex,
        builder: (context, selectedIndex, _) {
          // Comprobamos si este elemento está seleccionado comparando el `selectedIndex`
          final isSelected = selectedIndex == _getIndexForNavItem(text);

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isSelected ? Colors.indigo.withOpacity(0.1) : null,
            ),
            child: ListTile(
              selected: isSelected,
              selectedColor: Colors.indigo,
              leading: Icon(
                _getIconForNavItem(
                    text), // Asegúrate de implementar esta función
                color: isSelected ? Colors.indigo : Colors.grey,
              ),
              title: Text(
                text,
                style: TextStyle(
                  color: isSelected ? Colors.indigo : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

// Helper method to map text to index values
  int _getIndexForNavItem(String text) {
    switch (text) {
      case 'Edit Profile':
        return 0;
      case 'Preference':
        return 1;
      case 'Security':
        return 2;
      case 'Notifications':
        return 3;
      default:
        return -1;
    }
  }

  IconData _getIconForNavItem(String text) {
    switch (text) {
      case 'Edit Profile':
        return Icons.person_outline;
      case 'Preference':
        return Icons.settings_outlined;
      case 'Security':
        return Icons.security_outlined;
      case 'Notifications':
        return Icons.notifications_outlined;
      case 'Connected Accounts':
        return Icons.link_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  // Widget _buildTab(String text, {bool isSelected = false}) {
  //   return Padding(
  //     padding: const EdgeInsets.only(right: 24),
  //     child: Column(
  //       children: [
  //         Text(
  //           text,
  //           style: TextStyle(
  //             color: isSelected ? Colors.indigo : Colors.grey,
  //             fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
  //           ),
  //         ),
  //         const SizedBox(height: 4),
  //         if (isSelected)
  //           Container(
  //             height: 2,
  //             width: 80,
  //             color: Colors.indigo,
  //           ),
  //       ],
  //     ),
  //   );
  // }

//   Widget _buildTab(String title, {required bool isSelected, required int index}) {
//   return GestureDetector(
//     onTap: () {
//       setState(() {
//         _selectedIndex = index;
//       });
//     },
//     child: Container(
//       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//       decoration: BoxDecoration(
//         border: Border(
//           bottom: BorderSide(
//             color: isSelected ? Colors.blue : Colors.transparent,
//             width: 2,
//           ),
//         ),
//       ),
//       child: Text(
//         title,
//         style: TextStyle(
//           color: isSelected ? Colors.blue : Colors.grey,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     ),
//   );
// }

  Widget _buildTab(String title, int index) {
    return GestureDetector(
      onTap: () {
        _selectedIndex.value = index; // Actualiza solo el ValueNotifier
      },
      child: ValueListenableBuilder<int>(
        valueListenable: _selectedIndex,
        builder: (context, selectedIndex, _) {
          final isSelected = selectedIndex == index;
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isSelected ? Colors.blue : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget _buildInputField(TextEditingController controller, String label,
  //     {bool isPassword = false, bool isEmail = false, required bool enabled}) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 16),
  //     child: TextFormField(
  //       enabled: enabled,
  //       controller: controller,
  //       obscureText: isPassword && _obscurePassword,
  //       decoration: InputDecoration(
  //         labelText: label,
  //         border: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(8),
  //           borderSide: BorderSide(color: Colors.grey[300]!),
  //         ),
  //         enabledBorder: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(8),
  //           borderSide: BorderSide(color: Colors.grey[300]!),
  //         ),
  //         focusedBorder: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(8),
  //           borderSide: const BorderSide(color: Colors.indigo),
  //         ),
  //         filled: true,
  //         fillColor: Colors.grey[50],
  //         suffixIcon: isPassword
  //             ? IconButton(
  //                 icon: Icon(_obscurePassword
  //                     ? Icons.visibility_off
  //                     : Icons.visibility),
  //                 onPressed: () {
  //                   setState(() {
  //                     _obscurePassword = !_obscurePassword;
  //                   });
  //                 },
  //               )
  //             : null,
  //       ),
  //       validator: (value) {
  //         if (value == null || value.isEmpty) {
  //           return 'Por favor ingrese $label';
  //         }
  //         if (isEmail &&
  //             !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
  //           return 'Por favor ingrese un email válido';
  //         }
  //         return null;
  //       },
  //     ),
  //   );
  // }

  Widget _buildInputField(TextEditingController controller, String label,
      {bool isPassword = false, bool isEmail = false, required bool enabled}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ValueListenableBuilder<bool>(
        valueListenable: _obscurePasswordNotifier,
        builder: (context, obscurePassword, child) {
          return TextFormField(
            enabled: enabled,
            controller: controller,
            obscureText: isPassword && obscurePassword,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.indigo),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        _obscurePasswordNotifier.value = !obscurePassword;
                      },
                    )
                  : null,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese $label';
              }
              if (isEmail &&
                  !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                return 'Por favor ingrese un email válido';
              }
              return null;
            },
          );
        },
      ),
    );
  }

  // Widget _buildProfileEditSection() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         'Editar Perfil',
  //         style: GoogleFonts.roboto(
  //           fontSize: 24,
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //       const SizedBox(height: 24),
  //       Row(
  //         children: [
  //           Expanded(
  //             child: _buildInputField(
  //               nameController,
  //               'Nombre',
  //               enabled: _isEditMode,
  //             ),
  //           ),
  //           const SizedBox(width: 24),
  //           Expanded(
  //             child: _buildInputField(
  //               apellidoController,
  //               'Apellidos',
  //               enabled: _isEditMode,
  //             ),
  //           ),
  //         ],
  //       ),
  //       const SizedBox(height: 16),
  //       Row(
  //         children: [
  //           Expanded(
  //             child: _buildInputField(
  //               emailController,
  //               'Email',
  //               isEmail: true,
  //               enabled: _isEditMode,
  //             ),
  //           ),
  //           const SizedBox(width: 24),
  //           Expanded(
  //             child: _buildInputField(
  //               phoneController,
  //               'Teléfono',
  //               enabled: _isEditMode,
  //             ),
  //           ),
  //         ],
  //       ),
  //       const SizedBox(height: 32),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.end,
  //         children: [
  //           if (!_isEditMode)
  //             ElevatedButton(
  //               onPressed: () {
  //                 setState(() {
  //                   _isEditMode = true;
  //                 });
  //               },
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: Colors.indigo,
  //                 padding: const EdgeInsets.symmetric(
  //                   horizontal: 24,
  //                   vertical: 12,
  //                 ),
  //               ),
  //               child: const Row(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Icon(Icons.edit, color: Colors.white),
  //                   SizedBox(width: 8),
  //                   Text(
  //                     'Editar',
  //                     style: TextStyle(color: Colors.white),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           const SizedBox(width: 16),
  //           if (_isEditMode)
  //             OutlinedButton(
  //               onPressed: () {
  //                 setState(() {
  //                   _isEditMode = false;
  //                 });
  //               },
  //               style: OutlinedButton.styleFrom(
  //                 padding: const EdgeInsets.symmetric(
  //                   horizontal: 24,
  //                   vertical: 12,
  //                 ),
  //               ),
  //               child: const Row(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Icon(Icons.cancel, color: Colors.grey),
  //                   SizedBox(width: 8),
  //                   Text(
  //                     'Cancelar',
  //                     style: TextStyle(color: Colors.grey),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           const SizedBox(width: 16),
  //           if (_isEditMode)
  //             ElevatedButton(
  //               onPressed: () async {
  //                 if (_formKey.currentState!.validate()) {
  //                   await saveProfile();
  //                   setState(() {
  //                     _isEditMode = false;
  //                   });
  //                 }
  //               },
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: Colors.indigo,
  //                 padding: const EdgeInsets.symmetric(
  //                   horizontal: 24,
  //                   vertical: 12,
  //                 ),
  //               ),
  //               child: const Row(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Icon(Icons.save, color: Colors.white),
  //                   SizedBox(width: 8),
  //                   Text(
  //                     'Guardar',
  //                     style: TextStyle(color: Colors.white),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  Widget _buildProfileEditSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Botón de editar o cancelar
            ValueListenableBuilder<bool>(
              valueListenable: isEditing,
              builder: (context, editing, child) {
                return ElevatedButton.icon(
                  icon: Icon(editing ? Icons.cancel : Icons.edit),
                  label: Text(editing ? 'Cancelar' : 'Editar Perfil'),
                  onPressed: () {
                    isEditing.value = !editing;
                  },
                );
              },
            ),
            const SizedBox(width: 8),
            // Botón de guardar
            ValueListenableBuilder<bool>(
              valueListenable: isEditing,
              builder: (context, editing, child) {
                return ElevatedButton.icon(
                  icon: Icon(Icons.save,
                      color: editing ? Colors.white : Colors.grey),
                  label: Text(
                    'Guardar',
                    style:
                        TextStyle(color: editing ? Colors.white : Colors.grey),
                  ),
                  onPressed: editing
                      ? () {
                          saveProfile();
                          isEditing.value = false;
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: editing ? Colors.indigo : Colors.grey[300],
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Campos de entrada responsivos
        LayoutBuilder(
          builder: (context, constraints) {
            bool isLargeScreen = constraints.maxWidth > 600;

            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: isLargeScreen
                      ? (constraints.maxWidth / 2) - 8
                      : constraints.maxWidth,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: isEditing,
                    builder: (context, editing, child) {
                      return _buildInputField(
                        nameController,
                        'Nombre',
                        enabled: editing,
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: isLargeScreen
                      ? (constraints.maxWidth / 2) - 8
                      : constraints.maxWidth,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: isEditing,
                    builder: (context, editing, child) {
                      return _buildInputField(
                        apellidoController,
                        'Apellidos',
                        enabled: editing,
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: isLargeScreen
                      ? (constraints.maxWidth / 2) - 8
                      : constraints.maxWidth,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: isEditing,
                    builder: (context, editing, child) {
                      return _buildInputField(
                        emailController,
                        'Correo electrónico',
                        isEmail: true,
                        enabled: editing,
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: isLargeScreen
                      ? (constraints.maxWidth / 2) - 8
                      : constraints.maxWidth,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: isEditing,
                    builder: (context, editing, child) {
                      return _buildInputField(
                        phoneController,
                        'Teléfono',
                        enabled: editing,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // Widget _buildPasswordChangeSection() {
  //   return Padding(
  //     padding: const EdgeInsets.only(top: 32),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Cambiar Contraseña',
  //           style: GoogleFonts.roboto(
  //             fontSize: 20,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         const SizedBox(height: 16),
  //         _buildInputField(
  //           passwordController,
  //           'Contraseña Actual',
  //           isPassword: true,
  //           enabled: _isPasswordEditMode,
  //         ),
  //         _buildInputField(
  //           newPasswordController,
  //           'Nueva Contraseña',
  //           isPassword: true,
  //           enabled: _isPasswordEditMode,
  //         ),
  //         _buildInputField(
  //           confirmPasswordController,
  //           'Confirmar Nueva Contraseña',
  //           isPassword: true,
  //           enabled: _isPasswordEditMode,
  //         ),
  //         const SizedBox(height: 24),
  //         Center(
  //           child: LayoutBuilder(
  //             builder: (context, constraints) {
  //               bool showText = constraints.maxWidth > 280;
  //               return Row(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   if (!_isPasswordEditMode)
  //                     ElevatedButton(
  //                       onPressed: () {
  //                         setState(() {
  //                           _isPasswordEditMode = true;
  //                         });
  //                       },
  //                       style: ElevatedButton.styleFrom(
  //                         backgroundColor: Colors.indigo,
  //                         padding: const EdgeInsets.symmetric(
  //                           horizontal: 16,
  //                           vertical: 10,
  //                         ),
  //                         shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(8),
  //                         ),
  //                       ),
  //                       child: Row(
  //                         mainAxisSize: MainAxisSize.min,
  //                         children: [
  //                           const Icon(Icons.lock_outline, color: Colors.white),
  //                           if (showText) const SizedBox(width: 4),
  //                           if (showText)
  //                             const Text('Cambiar Contraseña',
  //                                 style: TextStyle(color: Colors.white)),
  //                         ],
  //                       ),
  //                     ),
  //                   const SizedBox(width: 8),
  //                   if (_isPasswordEditMode)
  //                     OutlinedButton(
  //                       onPressed: () {
  //                         setState(() {
  //                           _isPasswordEditMode = false;
  //                         });
  //                       },
  //                       style: OutlinedButton.styleFrom(
  //                         padding: const EdgeInsets.symmetric(
  //                           horizontal: 16,
  //                           vertical: 10,
  //                         ),
  //                         shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(8),
  //                         ),
  //                       ),
  //                       child: Row(
  //                         mainAxisSize: MainAxisSize.min,
  //                         children: [
  //                           const Icon(Icons.cancel, color: Colors.grey),
  //                           if (showText) const SizedBox(width: 4),
  //                           if (showText)
  //                             const Text('Cancelar',
  //                                 style: TextStyle(color: Colors.grey)),
  //                         ],
  //                       ),
  //                     ),
  //                   const SizedBox(width: 8),
  //                   if (_isPasswordEditMode)
  //                     ElevatedButton(
  //                       onPressed: () async {
  //                         if (_formKey.currentState!.validate()) {
  //                           await changePassword();
  //                           setState(() {
  //                             _isPasswordEditMode = false;
  //                           });
  //                         }
  //                       },
  //                       style: ElevatedButton.styleFrom(
  //                         backgroundColor: Colors.indigo,
  //                         padding: const EdgeInsets.symmetric(
  //                           horizontal: 16,
  //                           vertical: 10,
  //                         ),
  //                         shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(8),
  //                         ),
  //                       ),
  //                       child: Row(
  //                         mainAxisSize: MainAxisSize.min,
  //                         children: [
  //                           const Icon(Icons.save, color: Colors.white),
  //                           if (showText) const SizedBox(width: 4),
  //                           if (showText)
  //                             const Text('Guardar',
  //                                 style: TextStyle(color: Colors.white)),
  //                         ],
  //                       ),
  //                     ),
  //                 ],
  //               );
  //             },
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildPasswordChangeSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cambiar Contraseña',
            style: GoogleFonts.roboto(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<bool>(
            valueListenable: isPasswordEditMode,
            builder: (context, editing, child) {
              return Column(
                children: [
                  _buildInputField(
                    passwordController,
                    'Contraseña Actual',
                    isPassword: true,
                    enabled: editing,
                  ),
                  _buildInputField(
                    newPasswordController,
                    'Nueva Contraseña',
                    isPassword: true,
                    enabled: editing,
                  ),
                  _buildInputField(
                    confirmPasswordController,
                    'Confirmar Nueva Contraseña',
                    isPassword: true,
                    enabled: editing,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool showText = constraints.maxWidth > 280;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ValueListenableBuilder<bool>(
                      valueListenable: isPasswordEditMode,
                      builder: (context, editing, child) {
                        return editing
                            ? OutlinedButton(
                                onPressed: () {
                                  isPasswordEditMode.value = false;
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.cancel,
                                        color: Colors.grey),
                                    if (showText) const SizedBox(width: 4),
                                    if (showText)
                                      const Text(
                                        'Cancelar',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                  ],
                                ),
                              )
                            : ElevatedButton(
                                onPressed: () {
                                  isPasswordEditMode.value = true;
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.lock_outline,
                                        color: Colors.white),
                                    if (showText) const SizedBox(width: 4),
                                    if (showText)
                                      const Text(
                                        'Cambiar Contraseña',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                  ],
                                ),
                              );
                      },
                    ),
                    const SizedBox(width: 8),
                    ValueListenableBuilder<bool>(
                      valueListenable: isPasswordEditMode,
                      builder: (context, editing, child) {
                        return ElevatedButton(
                          onPressed: editing
                              ? () async {
                                  if (_formKey.currentState!.validate()) {
                                    await changePassword();
                                    isPasswordEditMode.value = false;
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.save, color: Colors.white),
                              if (showText) const SizedBox(width: 4),
                              if (showText)
                                const Text(
                                  'Guardar',
                                  style: TextStyle(color: Colors.white),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> saveProfile() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await _firestore.collection('Users').doc(currentUser.uid).update({
          'Nombre': nameController.text,
          'Apellidos': apellidoController.text,
          'email': emailController.text,
          'Telefono': phoneController.text,
        });

        // Show success SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Datos actualizados con éxito!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      // Show error SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar los datos: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> changePassword() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await currentUser.updatePassword(newPasswordController.text);
        // Update user's password in Firestore
        await _firestore.collection('Users').doc(currentUser.uid).update({
          'Contraseña': newPasswordController.text,
        });

        // Show success SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contraseña actualizada con éxito!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      // Show error SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar la contraseña: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
