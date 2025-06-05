import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  @override
  ProfileWidgetState createState() => ProfileWidgetState();
}

class ProfileWidgetState extends State<ProfileWidget> {
  final ValueNotifier<int> _selectedIndex =
      ValueNotifier<int>(0); // Notificador para evitar recargas completas
  //final _formKey = GlobalKey<FormState>();
  final ValueNotifier<bool> isEditing = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isPasswordEditMode = ValueNotifier(false);
  final ValueNotifier<bool> currentPasswordObscureNotifier =
      ValueNotifier<bool>(true);
  final ValueNotifier<bool> newPasswordObscureNotifier =
      ValueNotifier<bool>(true);
  final ValueNotifier<bool> confirmPasswordObscureNotifier =
      ValueNotifier<bool>(true);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File? _profileImage;
  Uint8List? _profileImageBytes;

  String? newPasswordError;
  String? confirmPasswordError;
  String? photoUrl = '';

  late TextEditingController nameController;
  late TextEditingController apellidoController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController currentPasswordController;
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
    //photoUrl = user?.photoURL;

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
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: [
  //           //Title row
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               Text(
  //                 'Mi Perfil',
  //                 style: GoogleFonts.roboto(
  //                   fontSize: 24,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //                 textAlign: TextAlign.center,
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 16),
  //           Row(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               // Barra lateral izquierda con navegación
  //               Card(
  //                 elevation: 2,
  //                 child: Container(
  //                   width: 250,
  //                   padding: const EdgeInsets.all(24),
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       // Sección de foto de perfil
  //                       Center(
  //                         child: Stack(
  //                           children: [
  //                             Container(
  //                               width: 120,
  //                               height: 120,
  //                               decoration: BoxDecoration(
  //                                 color: Colors.grey[200],
  //                                 shape: BoxShape.circle,
  //                               ),
  //                               child: photoUrl != null && photoUrl!.isNotEmpty
  //                                   ? ClipOval(
  //                                       child: Image.network(
  //                                         photoUrl.toString(),
  //                                         fit: BoxFit.cover,
  //                                         width: 120,
  //                                         height: 120,
  //                                       ),
  //                                     )
  //                                   : kIsWeb
  //                                       ? (_profileImageBytes != null
  //                                           ? ClipOval(
  //                                               child: Image.memory(
  //                                                 _profileImageBytes!,
  //                                                 fit: BoxFit.cover,
  //                                                 width: 120,
  //                                                 height: 120,
  //                                               ),
  //                                             )
  //                                           : const Icon(
  //                                               Icons.photo_library_outlined,
  //                                               size: 50,
  //                                               color: Colors.grey,
  //                                             ))
  //                                       : (_profileImage != null
  //                                           ? ClipOval(
  //                                               child: Image.file(
  //                                                 _profileImage!,
  //                                                 fit: BoxFit.cover,
  //                                                 width: 120,
  //                                                 height: 120,
  //                                               ),
  //                                             )
  //                                           : const Icon(
  //                                               Icons.photo_library_outlined,
  //                                               size: 50,
  //                                               color: Colors.grey,
  //                                             )),
  //                             ),
  //                             Positioned(
  //                               right: 0,
  //                               bottom: 0,
  //                               child: Container(
  //                                 padding: const EdgeInsets.all(8),
  //                                 decoration: const BoxDecoration(
  //                                   color: Colors.indigo,
  //                                   shape: BoxShape.circle,
  //                                 ),
  //                                 child: GestureDetector(
  //                                   onTap: () async {
  //                                     final picker = ImagePicker();
  //                                     final pickedFile = await picker.pickImage(
  //                                         source: ImageSource.camera);
  //                                     if (pickedFile != null) {
  //                                       if (kIsWeb) {
  //                                         final bytes =
  //                                             await pickedFile.readAsBytes();
  //                                         setState(() {
  //                                           _profileImageBytes = bytes;
  //                                         });
  //                                         await uploadProfileImage();
  //                                       } else {
  //                                         setState(() {
  //                                           _profileImage =
  //                                               File(pickedFile.path);
  //                                         });
  //                                         await uploadProfileImage();
  //                                       }
  //                                     }
  //                                   },
  //                                   child: const Icon(
  //                                     Icons.camera_alt,
  //                                     size: 20,
  //                                     color: Colors.white,
  //                                   ),
  //                                 ),
  //                               ),
  //                             )
  //                           ],
  //                         ),
  //                       ),
  //                       const SizedBox(height: 24),
  //                       _buildNavItem('Editar Perfil'),
  //                       _buildNavItem('Preferencias'),
  //                       _buildNavItem('Seguridad'),
  //                       _buildNavItem('Notificaciones'),
  //                       //_buildNavItem('Connected Accounts'),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(width: 24),
  //               // Área de contenido principal
  //               Expanded(
  //                 child: Card(
  //                   elevation: 2,
  //                   child: Container(
  //                     padding: const EdgeInsets.all(32),
  //                     child: ValueListenableBuilder<int>(
  //                       valueListenable: _selectedIndex,
  //                       builder: (context, selectedIndex, _) {
  //                         // Renderizamos la sección según el índice seleccionado
  //                         if (selectedIndex == 0) {
  //                           return _buildProfileEditSection();
  //                         } else if (selectedIndex == 2) {
  //                           return _buildPasswordChangeSection();
  //                         } else {
  //                           return const SizedBox.shrink();
  //                         }
  //                       },
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ],
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //Title row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Mi Perfil',
                  style: GoogleFonts.roboto(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
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
                                child: _buildProfileImage(),
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
                                  child: GestureDetector(
                                    onTap: _pickAndUploadImage,
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildNavItem('Editar Perfil'),
                        _buildNavItem('Preferencias'),
                        _buildNavItem('Seguridad'),
                        _buildNavItem('Notificaciones'),
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
          ],
        ),
      ),
    );
  }

  // Separated widget for better organization
  Widget _buildProfileImage() {
    // Priority 1: Show uploaded image from Firebase
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          photoUrl.toString(),
          fit: BoxFit.cover,
          width: 120,
          height: 120,
          // Add cache headers to force refresh
          headers: const {
            'Cache-Control': 'no-cache, no-store, must-revalidate',
          },
          errorBuilder: (context, error, stackTrace) {
            print('Error loading network image: $error');
            print('Image URL: $photoUrl');
            // Fallback to local image if network fails
            return _buildLocalImage();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          },
        ),
      );
    }

    // Priority 2: Show local images while uploading or if no network image
    return _buildLocalImage();
  }

  Widget _buildLocalImage() {
    if (kIsWeb && _profileImageBytes != null) {
      return ClipOval(
        child: Image.memory(
          _profileImageBytes!,
          fit: BoxFit.cover,
          width: 120,
          height: 120,
        ),
      );
    }

    if (!kIsWeb && _profileImage != null) {
      return ClipOval(
        child: Image.file(
          _profileImage!,
          fit: BoxFit.cover,
          width: 120,
          height: 120,
        ),
      );
    }

    return const Icon(
      Icons.photo_library_outlined,
      size: 50,
      color: Colors.grey,
    );
  }

  // Improved image picker with better error handling
  Future<void> _pickAndUploadImage() async {
    try {
      final picker = ImagePicker();

      // Show dialog to choose between camera and gallery
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Seleccionar imagen'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Cámara'),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Galería'),
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
              ],
            ),
          );
        },
      );

      if (source == null) return;

      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        // Show loading indicator
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Subiendo imagen...'),
                ],
              ),
              duration: Duration(seconds: 5),
            ),
          );
        }

        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _profileImageBytes = bytes;
          });
        } else {
          setState(() {
            _profileImage = File(pickedFile.path);
          });
        }

        await uploadProfileImage();
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e')),
        );
      }
    }
  }

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Mi Perfil',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildTab('Editar Perfil', 0),
                        _buildTab('Preferencias', 1),
                        _buildTab('Seguridad', 2),
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
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(String text) {
    return GestureDetector(
      onTap: () {
        // Actualizamos el valor de `_selectedIndex` directamente para evitar el uso de `setState`
        switch (text) {
          case 'Editar Perfil':
            _selectedIndex.value = 0;
            break;
          case 'Preferencias':
            _selectedIndex.value = 1;
            break;
          case 'Seguridad':
            _selectedIndex.value = 2;
            break;
          case 'Notificaciones':
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
      case 'Editar Perfil':
        return 0;
      case 'Preferencias':
        return 1;
      case 'Seguridad':
        return 2;
      case 'Notificaciones':
        return 3;
      default:
        return -1;
    }
  }

  IconData _getIconForNavItem(String text) {
    switch (text) {
      case 'Editar Perfil':
        return Icons.person_outline;
      case 'Preferencias':
        return Icons.settings_outlined;
      case 'Seguridad':
        return Icons.security_outlined;
      case 'Notificaciones':
        return Icons.notifications_outlined;
      // case 'Connected Accounts':
      //   return Icons.link_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

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

  Widget _buildInputField(
    TextEditingController controller,
    String label, {
    bool isPassword = false,
    bool isEmail = false,
    required bool enabled,
    String? errorText,
    ValueNotifier<bool>?
        obscureNotifier, // Nueva variable para el ValueNotifier
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ValueListenableBuilder<bool>(
        valueListenable: obscureNotifier ??
            ValueNotifier(false), // Utilizamos el ValueNotifier proporcionado
        builder: (context, obscurePassword, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
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
                            obscureNotifier?.value = !obscurePassword;
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
              ),
              // Mostrar el mensaje de error en rojo debajo del campo de entrada
              if (errorText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    errorText,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileEditSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        const SizedBox(height: 24),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              ValueListenableBuilder<bool>(
                valueListenable: isEditing,
                builder: (context, editing, child) {
                  return ElevatedButton.icon(
                    icon: Icon(Icons.save,
                        color: editing ? Colors.white : Colors.grey),
                    label: Text(
                      'Guardar',
                      style: TextStyle(
                          color: editing ? Colors.white : Colors.grey),
                    ),
                    onPressed: editing
                        ? () {
                            saveProfile();
                            isEditing.value = false;
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          editing ? Colors.indigo : Colors.grey[300],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordChangeSection() {
    final formKey = GlobalKey<FormState>();

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
          Form(
            key: formKey,
            child: ValueListenableBuilder<bool>(
              valueListenable: isPasswordEditMode,
              builder: (context, editing, child) {
                return Column(
                  children: [
                    _buildInputField(
                      passwordController,
                      'Contraseña Actual',
                      isPassword: true,
                      enabled: editing,
                      obscureNotifier: currentPasswordObscureNotifier,
                    ),
                    _buildInputField(
                      newPasswordController,
                      'Nueva Contraseña',
                      isPassword: true,
                      enabled: editing,
                      obscureNotifier: newPasswordObscureNotifier,
                      errorText: newPasswordError,
                    ),
                    _buildInputField(
                      confirmPasswordController,
                      'Confirmar Nueva Contraseña',
                      isPassword: true,
                      enabled: editing,
                      obscureNotifier: confirmPasswordObscureNotifier,
                      errorText: confirmPasswordError,
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: isPasswordEditMode,
                  builder: (context, editing, child) {
                    return ElevatedButton.icon(
                      icon: Icon(editing ? Icons.cancel : Icons.lock_outline),
                      label: Text(editing ? 'Cancelar' : 'Cambiar Contraseña'),
                      onPressed: () {
                        isPasswordEditMode.value = !editing;
                      },
                    );
                  },
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<bool>(
                  valueListenable: isPasswordEditMode,
                  builder: (context, editing, child) {
                    return ElevatedButton.icon(
                      icon: Icon(Icons.save,
                          color: editing ? Colors.white : Colors.grey),
                      label: Text('Guardar',
                          style: TextStyle(
                              color: editing ? Colors.white : Colors.grey)),
                      onPressed: editing
                          ? () async {
                              if (formKey.currentState!.validate()) {
                                await changePassword();
                                isPasswordEditMode.value = false;
                                passwordController.clear();
                                newPasswordController.clear();
                                confirmPasswordController.clear();
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            editing ? Colors.indigo : Colors.grey[300],
                      ),
                    );
                  },
                ),
              ],
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

        if (!mounted) return;
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
        // Reautenticación del usuario con la contraseña actual
        AuthCredential credential = EmailAuthProvider.credential(
          email: currentUser.email!,
          password: passwordController.text,
        );

        await currentUser.reauthenticateWithCredential(credential);
        if (!mounted) return;
        // Validación de la longitud de la nueva contraseña
        if (newPasswordController.text.length < 8) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('La nueva contraseña debe tener al menos 8 caracteres.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Validación para verificar si la nueva contraseña coincide con la confirmación
        if (newPasswordController.text != confirmPasswordController.text) {
          setState(() {
            confirmPasswordError = 'Las contraseñas no coinciden';
          });
          return;
        } else {
          // Si las contraseñas coinciden, limpiamos cualquier mensaje de error anterior
          setState(() {
            confirmPasswordError = null;
          });
        }

        // Actualización de la nueva contraseña
        await currentUser.updatePassword(newPasswordController.text);

        if (!mounted) return;
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Contraseña actualizada con éxito!'),
            backgroundColor: Colors.green,
          ),
        );

        // Limpiar los campos de contraseña después de la actualización
        passwordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();
      }
    } catch (error) {
      // Mostrar mensaje de error si la reautenticación falla
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La contraseña actual no es válida.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Improved upload function with better error handling and validation
  Future<void> uploadProfileImage() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario no autenticado')),
        );
      }
      return;
    }

    try {
      String downloadUrl = '';

      // Create a reference with timestamp to avoid caching issues
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images/${user.uid}_$timestamp.jpg');

      if (kIsWeb && _profileImageBytes != null) {
        // Upload for web
        final uploadTask = ref.putData(
          _profileImageBytes!,
          SettableMetadata(
            contentType: 'image/jpeg',
            customMetadata: {
              'userId': user.uid,
              'uploadedAt': DateTime.now().toIso8601String(),
            },
          ),
        );

        final snapshot = await uploadTask;
        downloadUrl = await snapshot.ref.getDownloadURL();
      } else if (!kIsWeb && _profileImage != null) {
        // Upload for mobile
        final uploadTask = ref.putFile(
          _profileImage!,
          SettableMetadata(
            contentType: 'image/jpeg',
            customMetadata: {
              'userId': user.uid,
              'uploadedAt': DateTime.now().toIso8601String(),
            },
          ),
        );

        final snapshot = await uploadTask;
        downloadUrl = await snapshot.ref.getDownloadURL();
      }

      if (downloadUrl.isNotEmpty) {
        // Update Firestore with additional user data structure
        await FirebaseFirestore.instance.collection('Users').doc(user.uid).set({
          'photoUrl': downloadUrl,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Update Auth profile
        await user.updatePhotoURL(downloadUrl);

        // Update the local state properly
        setState(() {
          photoUrl = downloadUrl;
          // Clear local images since we now have the uploaded URL
          _profileImageBytes = null;
          _profileImage = null;
        });

        print('Profile image uploaded successfully: $downloadUrl');
      }

      if (!mounted) return;

      // Hide loading snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto de perfil actualizada con éxito'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error uploading profile image: $e');

      if (!mounted) return;

      // Hide loading snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar la foto de perfil: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

// Additional helper method to refresh profile data
  Future<void> refreshProfileData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          setState(() {
            photoUrl = data['photoUrl'] as String?;
          });
          print('Refreshed photoUrl: $photoUrl');
        }
      } catch (e) {
        print('Error refreshing profile data: $e');
      }
    }
  }
}
