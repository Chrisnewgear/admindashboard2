import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  @override
  ProfileWidgetState createState() => ProfileWidgetState();
}

class ProfileWidgetState extends State<ProfileWidget> {
  // --- Controllers ---
  late final TextEditingController nameController;
  late final TextEditingController apellidoController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController currentPasswordController;
  late final TextEditingController newPasswordController;
  late final TextEditingController confirmPasswordController;
  late final TextEditingController phoneController;
  late final TextEditingController locationController;

  // --- Notifiers ---
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);
  final ValueNotifier<bool> isEditing = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isPasswordEditMode = ValueNotifier(false);
  final ValueNotifier<bool> currentPasswordObscureNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<bool> newPasswordObscureNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<bool> confirmPasswordObscureNotifier = ValueNotifier<bool>(true);

  // --- State ---
  File? _profileImage;
  Uint8List? _profileImageBytes;
  String? photoUrl = '';
  String? newPasswordError;
  String? confirmPasswordError;
  bool _isUploading = false;
  //final bool _isCameraHovered = false;

  // --- Services ---
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _photoUrl;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
    initializeProfile();
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

  Future<void> _loadCurrentPhotoUrl() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .get();
    if (doc.exists) {
      setState(() {
        _photoUrl = doc.data()?['photoUrl'] as String?;
      });
    }
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
        final firestorePhotoUrl = userData['photoUrl'] as String? ?? '';

        // Update controllers with user data
        nameController.text = userData['Nombre'] ?? '';
        apellidoController.text = userData['Apellidos'] ?? '';
        emailController.text = userData['email'] ?? '';
        phoneController.text = userData['Telefono'] ?? '';

        return Scaffold(
          body: isDesktop
              ? _buildDesktopLayout(
                  context, firestorePhotoUrl) // Pass the URL from Firestore
              : _buildMobileLayout(
                  context, firestorePhotoUrl), // Pass the URL from Firestore
        );
      },
    );
  }

  Widget _buildDesktopLayout(BuildContext context, String photoUrl) {
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
                                child: _buildProfileImage(photoUrl),
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
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: _pickAndUploadImage,
                                      child: const Icon(
                                        Icons.camera_alt,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // IconButton(
                              //   onPressed: () {
                              //     refreshProfileData();
                              //     forceImageRefresh();
                              //   },
                              //   icon: const Icon(Icons.refresh),
                              // )
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

  /// Helper to build the profile image with loading and error handling.
  Widget _buildProfileImage(String? photoUrl) {
    debugPrint('=== DEBUG: _buildProfileImage called ===');
    debugPrint('photoUrl: "$photoUrl"');
    debugPrint('_isUploading: $_isUploading');

    if (_isUploading) {
      return _buildLocalImage();
    }
    if (photoUrl != null && photoUrl.trim().isNotEmpty) {
      debugPrint('Attempting to load network image: $photoUrl');
      return ClipOval(
        child: Image.network(
          photoUrl,
          fit: BoxFit.cover,
          width: 120,
          height: 120,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('ERROR loading network image: $error');
            return _buildLocalImage();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
        ),
      );
    }
    debugPrint('Falling back to local image or placeholder');
    return _buildLocalImage();
  }

  /// Helper to build the local image or placeholder.
  Widget _buildLocalImage() {
    debugPrint('=== DEBUG: _buildLocalImage called ===');
    debugPrint('kIsWeb: $kIsWeb');
    debugPrint('_profileImageBytes != null: \\${_profileImageBytes != null}');
    debugPrint('_profileImage != null: \\${_profileImage != null}');
    debugPrint('_isUploading: $_isUploading');

    if (kIsWeb && _profileImageBytes != null) {
      debugPrint('Showing web local image');
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
      debugPrint('Showing mobile local image');
      return ClipOval(
        child: Image.file(
          _profileImage!,
          fit: BoxFit.cover,
          width: 120,
          height: 120,
        ),
      );
    }
    if (_isUploading) {
      debugPrint('Showing upload progress indicator');
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    debugPrint('Showing default placeholder');
    return Container(
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
    );
  }

  Future<void> initializeProfile() async {
    debugPrint('=== DEBUG: initializeProfile called ===');

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        debugPrint('Loading profile for user: ${user.uid}');

        // First check Firebase Auth
        debugPrint('Firebase Auth photoURL: "${user.photoURL}"');

        // Then check Firestore
        final doc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          final firestorePhotoUrl = data['photoUrl'] as String?;
          debugPrint('Firestore photoUrl: "$firestorePhotoUrl"');

          setState(() {
            // Use the non-empty URL, prefer Firestore over Auth
            if (firestorePhotoUrl != null &&
                firestorePhotoUrl.trim().isNotEmpty) {
              photoUrl = firestorePhotoUrl;
            } else if (user.photoURL != null &&
                user.photoURL!.trim().isNotEmpty) {
              photoUrl = user.photoURL;
            } else {
              photoUrl = null; // Explicitly set to null instead of empty string
            }
          });

          debugPrint('Initialized photoUrl to: "$photoUrl"');
        } else {
          debugPrint('No Firestore document found');
          setState(() {
            photoUrl =
                user.photoURL?.trim().isEmpty == true ? null : user.photoURL;
          });
        }
      } catch (e) {
        debugPrint('Error initializing profile: $e');
      }
    }
  }

  // Improved image picker with better error handling
  Future<void> _pickAndUploadImage() async {
    try {
      final picker = ImagePicker();

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
        // Update local image first
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

        // Then upload
        await uploadProfileImage();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e')),
        );
      }
    }
  }

  Widget _buildMobileLayout(BuildContext context, String photoUrl) {
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

  Future<void> uploadProfileImage() async {
    debugPrint('=== DEBUG: uploadProfileImage started ===');

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('ERROR: User not authenticated');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario no autenticado')),
        );
      }
      return;
    }

    debugPrint('User UID: ${user.uid}');

    setState(() {
      _isUploading = true;
    });

    try {
      String downloadUrl = '';
      final imagePath = 'profile_images/${user.uid}.jpg'; // Always use the same path for the user

      debugPrint('Creating Firebase Storage reference: $imagePath');
      final ref = FirebaseStorage.instance.ref().child(imagePath);

      if (kIsWeb && _profileImageBytes != null) {
        debugPrint('Uploading web image, size: \\${_profileImageBytes!.length} bytes');

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
        debugPrint('Web upload complete. Download URL: "$downloadUrl"');
      } else if (!kIsWeb && _profileImage != null) {
        debugPrint('Uploading mobile image: \\${_profileImage!.path}');

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
        debugPrint('Mobile upload complete. Download URL: "$downloadUrl"');
      }

      if (downloadUrl.isNotEmpty && downloadUrl.trim().isNotEmpty) {
        debugPrint('Updating Firestore with URL: "$downloadUrl"');

        // Update Firestore
        await FirebaseFirestore.instance.collection('Users').doc(user.uid).set({
          'photoUrl': downloadUrl.trim(), // Ensure no whitespace
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        debugPrint('Firestore updated successfully');

        // Update Firebase Auth
        await user.updatePhotoURL(downloadUrl.trim());
        debugPrint('Firebase Auth profile updated');

        // Verify the update by re-reading from Firestore
        await Future.delayed(const Duration(milliseconds: 500));

        final verifyDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get(const GetOptions(source: Source.server));

        if (verifyDoc.exists) {
          final verifyData = verifyDoc.data();
          final verifiedUrl = verifyData?['photoUrl'] as String?;
          debugPrint('Verified Firestore photoUrl: "$verifiedUrl"');

          // Update local state with verified URL
          setState(() {
            photoUrl = verifiedUrl?.trim().isEmpty == true
                ? null
                : verifiedUrl?.trim();
          });

          debugPrint('Updated local photoUrl to: "$photoUrl"');
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto de perfil actualizada con éxito'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        debugPrint('ERROR: downloadUrl is empty or invalid');
      }
    } catch (e, stackTrace) {
      debugPrint('ERROR uploading profile image: $e');
      debugPrint('StackTrace: $stackTrace');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar la foto de perfil: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });

        // Clear local images after successful upload
        if (photoUrl != null && photoUrl!.trim().isNotEmpty) {
          debugPrint('Clearing local images after successful upload');
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _profileImageBytes = null;
                _profileImage = null;
              });
              debugPrint('Local images cleared');
            }
          });
        }
      }
    }
  }

// Enhanced refresh method
  Future<void> refreshProfileData() async {
    debugPrint('=== DEBUG: refreshProfileData called ===');

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        debugPrint('Refreshing user data for UID: ${user.uid}');

        // Force refresh from server
        await user.reload();
        final refreshedUser = FirebaseAuth.instance.currentUser;
        debugPrint(
            'Firebase Auth photoURL after reload: ${refreshedUser?.photoURL}');

        // Get fresh data from Firestore
        final doc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get(const GetOptions(source: Source.server));

        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          final newPhotoUrl = data['photoUrl'] as String?;

          debugPrint('Firestore photoUrl: $newPhotoUrl');
          debugPrint('Current local photoUrl: $photoUrl');

          setState(() {
            photoUrl = newPhotoUrl;
          });

          debugPrint('Updated local photoUrl to: $photoUrl');
        } else {
          debugPrint('Firestore document does not exist or has no data');
        }
      } catch (e, stackTrace) {
        debugPrint('Error refreshing profile data: $e');
        debugPrint('StackTrace: $stackTrace');
      }
    } else {
      debugPrint('No authenticated user found');
    }
  }

// Add this method to force refresh the image widget
  void forceImageRefresh() {
    setState(() {
      // This will trigger a rebuild of the image widget
    });
  }

  // Add this method to test the image URL directly
  Future<void> testImageUrl() async {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      debugPrint('Testing image URL: $photoUrl');

      try {
        final response = await http.get(Uri.parse(photoUrl!));
        debugPrint('HTTP Response status: ${response.statusCode}');
        debugPrint('HTTP Response headers: ${response.headers}');

        if (response.statusCode == 200) {
          debugPrint('Image URL is accessible');
        } else {
          debugPrint('Image URL returned error: ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('Error testing image URL: $e');
      }
    }
  }

  // Add a manual refresh button for testing
  Widget buildRefreshButton() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: refreshProfileData,
          child: const Text('Refresh Profile'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: testImageUrl,
          child: const Text('Test Image URL'),
        ),
        const SizedBox(height: 8),
        Text(
          'Current photoUrl: ${photoUrl ?? "null"}',
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
