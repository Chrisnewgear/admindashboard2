import 'dart:math';
import 'package:admindashboard/models/clients.dart';
import 'package:admindashboard/pages/clients/widgets/clients_paginated_table.dart';
import 'package:admindashboard/pages/myteam/widgets/myteam_paginated_table.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

class MyTeamPage extends StatefulWidget {
  const MyTeamPage({super.key});

  @override
  State<MyTeamPage> createState() => _MyTeamPageState();
}

class _MyTeamPageState extends State<MyTeamPage> {
  //final _formKey = GlobalKey<FormState>();
  //String selectedRole = 'Cliente';
  //List<String> roles = ['Vendedor', 'Supervisor'];
  bool isLoading = false;
  String currentVendorCode = '';
  List<Cliente> clientes = [];

  final TextEditingController _nombresController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _fechaIngresoController = TextEditingController();
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _empresaController = TextEditingController();
  final TextEditingController _codVendedorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserCodeAndUsers();
  }

  Future<void> _loadUserCodeAndUsers() async {
    try {
      // Get the current user
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Fetch the user document from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          // Set the _codVendedorController with the user's code
          String userCode = userDoc.get('Codigo') ?? '';
          setState(() {
            _codVendedorController.text = userCode;
            currentVendorCode = _codVendedorController.text;
          });

          if (userDoc.exists) {
            bool hasRole = userDoc.get('Role') == 'None' ? false : true;

            if (hasRole) {
              await _loadUsers();
            } else {
              setState(() {
                clientes = [];
              });
            }
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              //Text('Error al cargar información del usuario y clientes: $e'),
              Text('No tiene asignado un rol.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _loadUsers() async {
    setState(() {
      isLoading = true; // Activar loading al inicio de la carga
    });

    try {
      // Obtener el usuario actualmente autenticado
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }

      // Consultar la colección 'Clients' filtrando por el UserId del usuario actual
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Clients')
          .where('UserId', isEqualTo: user.uid)
          .get();

      setState(() {
        clientes = querySnapshot.docs
            .map((doc) => Cliente.fromFirestore(doc))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false; // Desactivar loading incluso si hay error
      });

      // Mostrar un mensaje de error al usuario
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar los clientes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearFormFields() {
    _nombresController.clear();
    _apellidosController.clear();
    _emailController.clear();
    _telefonoController.clear();
    _direccionController.clear();
    _empresaController.clear();
  }

  // void _showFormDialog(BuildContext context, Cliente? client, bool editModeOn) {
  //   final formKey = GlobalKey<FormState>();
  //   final ValueNotifier<bool> isEditable = editModeOn
  //       ? ValueNotifier<bool>(true)
  //       : ValueNotifier<bool>(client == null);

  //   if (client != null) {
  //     _nombresController.text = client.nombre;
  //     _apellidosController.text = client.apellido;
  //     _emailController.text = client.email;
  //     _telefonoController.text = client.telefono;
  //     _codigoController.text = client.codigo;
  //     _direccionController.text = client.direccion;
  //     _empresaController.text = client.empresa;
  //     _fechaIngresoController.text =
  //         DateFormat('dd/MM/yyyy').format(client.fechaIngreso);
  //   } else {
  //     _nombresController.clear();
  //     _apellidosController.clear();
  //     _emailController.clear();
  //     _telefonoController.clear();
  //     _codigoController.clear();
  //     _direccionController.clear();
  //     _empresaController.clear();
  //     _codVendedorController.clear();
  //     _fechaIngresoController.text =
  //         DateFormat('dd/MM/yyyy').format(DateTime.now());
  //   }

  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Dialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(16),
  //         ),
  //         elevation: 0,
  //         backgroundColor: Colors.transparent,
  //         child: LayoutBuilder(
  //           builder: (context, constraints) {
  //             double modalWidth;
  //             if (constraints.maxWidth > 1024) {
  //               // iPad Pro y pantallas grandes
  //               modalWidth =
  //                   constraints.maxWidth * 0.5; // 50% del ancho disponible
  //             } else if (constraints.maxWidth > 768) {
  //               // iPads regulares
  //               modalWidth = constraints.maxWidth * 0.7;
  //             } else {
  //               modalWidth = constraints.maxWidth * 0.9;
  //             }

  //             return Container(
  //               width: modalWidth,
  //               padding: const EdgeInsets.all(24),
  //               decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: BorderRadius.circular(16),
  //               ),
  //               child: SingleChildScrollView(
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: <Widget>[
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                       children: [
  //                         Text(
  //                           client == null ? 'Nuevo Cliente' : 'Editar Cliente',
  //                           style: const TextStyle(
  //                             fontSize: 24,
  //                             fontWeight: FontWeight.bold,
  //                             color: Colors.black87,
  //                           ),
  //                         ),
  //                         IconButton(
  //                           icon:
  //                               const Icon(Icons.close, color: Colors.black54),
  //                           onPressed: () => Navigator.of(context).pop(),
  //                         ),
  //                       ],
  //                     ),
  //                     const SizedBox(height: 24),
  //                     Form(
  //                       key: formKey,
  //                       child: ValueListenableBuilder<bool>(
  //                         valueListenable: isEditable,
  //                         builder: (context, editable, _) {
  //                           bool isLargeScreen = constraints.maxWidth > 986;
  //                           return Column(
  //                             children: [
  //                               _buildResponsiveRow(isLargeScreen, [
  //                                 _buildInputField(
  //                                     _nombresController, 'Nombres*',
  //                                     enabled: editable),
  //                                 _buildInputField(
  //                                     _apellidosController, 'Apellidos*',
  //                                     enabled: editable),
  //                               ]),
  //                               _buildResponsiveRow(isLargeScreen, [
  //                                 _buildInputField(_emailController, 'Email',
  //                                     isEmail: true, enabled: editable),
  //                                 _buildInputField(
  //                                     _telefonoController, 'Teléfono*',
  //                                     enabled: editable),
  //                               ]),
  //                               _buildResponsiveRow(isLargeScreen, [
  //                                 _buildInputField(
  //                                     _empresaController, 'Empresa',
  //                                     enabled: editable),
  //                                 _buildDatePicker(
  //                                     context,
  //                                     _fechaIngresoController,
  //                                     'Fecha de Ingreso',
  //                                     enabled: editable),
  //                               ]),
  //                               _buildResponsiveRow(isLargeScreen, [
  //                                 _buildInputField(
  //                                     _direccionController, 'Dirección',
  //                                     enabled: editable),
  //                               ])
  //                             ],
  //                           );
  //                         },
  //                       ),
  //                     ),
  //                     const SizedBox(height: 24),
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.end,
  //                       children: [
  //                         if (client != null)
  //                           Flexible(
  //                             child: ConstrainedBox(
  //                               constraints: BoxConstraints(
  //                                 maxWidth:
  //                                     MediaQuery.of(context).size.width < 768
  //                                         ? double.infinity
  //                                         : 200,
  //                               ),
  //                               child: ValueListenableBuilder<bool>(
  //                                 valueListenable: isEditable,
  //                                 builder: (context, editable, _) {
  //                                   return ElevatedButton.icon(
  //                                     style: ElevatedButton.styleFrom(
  //                                       padding: EdgeInsets.symmetric(
  //                                         horizontal: MediaQuery.of(context)
  //                                                     .size
  //                                                     .width <
  //                                                 768
  //                                             ? 12
  //                                             : 16,
  //                                         vertical: 12,
  //                                       ),
  //                                     ),
  //                                     onPressed: () {
  //                                       isEditable.value = !isEditable.value;
  //                                     },
  //                                     icon: editable
  //                                         ? const Icon(Icons.edit_off)
  //                                         : const Icon(Icons.edit),
  //                                     label: MediaQuery.of(context).size.width <
  //                                             768
  //                                         ? const SizedBox.shrink()
  //                                         : Text(editable
  //                                             ? 'Cancelar Edición'
  //                                             : 'Editar'),
  //                                   );
  //                                 },
  //                               ),
  //                             ),
  //                           ),
  //                         if (client != null) const SizedBox(width: 8),
  //                         Flexible(
  //                           child: ConstrainedBox(
  //                             constraints: BoxConstraints(
  //                               maxWidth:
  //                                   MediaQuery.of(context).size.width < 768
  //                                       ? double.infinity
  //                                       : 200,
  //                             ),
  //                             child: TextButton.icon(
  //                               onPressed: () => Navigator.of(context).pop(),
  //                               icon: const Icon(Icons.cancel),
  //                               label: MediaQuery.of(context).size.width < 768
  //                                   ? const SizedBox.shrink()
  //                                   : const Text('Cancelar'),
  //                               style: TextButton.styleFrom(
  //                                 padding: EdgeInsets.symmetric(
  //                                   horizontal:
  //                                       MediaQuery.of(context).size.width < 768
  //                                           ? 12
  //                                           : 16,
  //                                   vertical: 12,
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                         const SizedBox(width: 8),
  //                         Flexible(
  //                           child: ConstrainedBox(
  //                             constraints: BoxConstraints(
  //                               maxWidth:
  //                                   MediaQuery.of(context).size.width < 768
  //                                       ? double.infinity
  //                                       : 200,
  //                             ),
  //                             child: ElevatedButton.icon(
  //                               style: ElevatedButton.styleFrom(
  //                                 backgroundColor: Colors.indigo,
  //                                 shape: RoundedRectangleBorder(
  //                                   borderRadius: BorderRadius.circular(8),
  //                                 ),
  //                                 padding: EdgeInsets.symmetric(
  //                                   horizontal:
  //                                       MediaQuery.of(context).size.width < 768
  //                                           ? 12
  //                                           : 16,
  //                                   vertical: 12,
  //                                 ),
  //                               ),
  //                               onPressed: () {
  //                                 if (formKey.currentState!.validate()) {
  //                                   _saveOrUpdateClient(context, client);
  //                                   Navigator.of(context).pop();
  //                                 }
  //                               },
  //                               icon: const Icon(
  //                                 Icons.save,
  //                                 color: Colors.white,
  //                               ),
  //                               label: MediaQuery.of(context).size.width < 768
  //                                   ? const SizedBox.shrink()
  //                                   : const Text(
  //                                       'Guardar',
  //                                       style: TextStyle(color: Colors.white),
  //                                     ),
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             );
  //           },
  //         ),
  //       );
  //     },
  //   );
  // }

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _fechaIngresoController.dispose();
    _codigoController.dispose();
    _empresaController.dispose();
    _direccionController.dispose();
    _codVendedorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Team',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            Expanded(
              child: ResponsiveMyTeamTable(isLoading: true), // Corrección aquí
            ),
          ],
        ),
      ),
    );
  }
}

void showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const Dialog(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Guardando cliente..."),
            ],
          ),
        ),
      );
    },
  );
}
