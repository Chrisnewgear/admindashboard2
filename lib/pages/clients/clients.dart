// ignore_for_file: duplicate_import

import 'dart:math';

import 'package:admindashboard/models/clients.dart';
import 'package:admindashboard/pages/clients/widgets/clients_paginated_table.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});

  @override
  _ClientsPageState createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  //final _formKey = GlobalKey<FormState>();
  //String selectedRole = 'Cliente';
  //List<String> roles = ['Vendedor', 'Supervisor'];
  String currentVendorCode = '';
  List<Clients> clients = [];

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

  // Future<void> _loadUserCodeAndUsers() async {
  //   try {
  //     // Get the current user
  //     User? currentUser = FirebaseAuth.instance.currentUser;
  //     if (currentUser != null) {
  //       if (kDebugMode) {
  //         print('Current user UID: ${currentUser.uid}');
  //       }

  //       // Fetch the user document from Firestore
  //       DocumentSnapshot userDoc = await FirebaseFirestore.instance
  //           .collection('Users')
  //           .doc(currentUser.uid)
  //           .get();

  //       if (userDoc.exists) {
  //         if (kDebugMode) {
  //           print('User document data: ${userDoc.data()}');
  //         }

  //         // Set the _codVendedorController with the user's code
  //         String userCode = userDoc.get('Codigo') ?? '';
  //         setState(() {
  //           _codVendedorController.text = userCode;
  //           currentVendorCode = _codVendedorController.text;
  //         });

  //         if (kDebugMode) {
  //           print('Código de vendedor cargado: $userCode');
  //           print('Código de vendedor cargado: $userCode');
  //         }
  //       } else {
  //         if (kDebugMode) {
  //           print('User document does not exist for UID: ${currentUser.uid}');
  //         }
  //       }
  //     } else {
  //       if (kDebugMode) {
  //         print('No user is currently logged in');
  //       }
  //     }

  //     // Load clients
  //     await _loadUsers();
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('Error loading user code and clients: $e');
  //     }
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content:
  //             Text('Error al cargar información del usuario y clientes: $e'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }

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
        }
      }

      await _loadUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Error al cargar información del usuario y clientes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadUsers() async {
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
        clients = querySnapshot.docs
            .map((doc) => Clients.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      // Mostrar un mensaje de error al usuario
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar los clientes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String> _getNextClientCode() async {
    Random random = Random();
    String code = '';
    bool isUnique = false;

    while (!isUnique) {
      // Generar un número aleatorio de 6 dígitos
      int randomNumber = random.nextInt(900000) + 100000; // Asegura 6 dígitos
      code = 'USR$randomNumber';

      // Verificar si el código ya existe en Firebase
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Clients')
          .where('Codigo', isEqualTo: code)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        isUnique = true; // El código es único
      }
    }

    return code;
  }

  // Future<void> _saveOrUpdateClient(Clients? existingClient) async {
  //   try {
  //     // Obtener el código del vendedor actual
  //     // currentVendorCode = _codVendedorController.text;

  //     if (kDebugMode) {
  //       print('Código del vendedor actual: $currentVendorCode');
  //     }

  //     // Obtener el UserId del usuario actualmente logeado
  //     final user = FirebaseAuth.instance.currentUser;
  //     if (user == null) {
  //       throw Exception('No hay ningún usuario logeado.');
  //     }

  //     final userId = user.uid;

  //     final clientData = {
  //       'Nombre': _nombresController.text,
  //       'Apellidos': _apellidosController.text,
  //       'email': _emailController.text,
  //       'Telefono': _telefonoController.text,
  //       'Direccion': _direccionController.text,
  //       'Empresa': _empresaController.text,
  //       'Codigo': _codigoController.text,
  //       'CodVendedor': currentVendorCode, // Usar el código del vendedor actual
  //       'UserId': userId, // Guardar el UserId del usuario logeado
  //       'updatedAt': Timestamp.now(),
  //     };

  //     if (kDebugMode) {
  //       print('Datos del cliente a guardar: $clientData');
  //     }

  //     if (existingClient == null) {
  //       // Crear un nuevo cliente
  //       final nextCode = await _getNextClientCode();
  //       clientData['Codigo'] = nextCode;
  //       clientData['createdAt'] = Timestamp.now();

  //       DocumentReference docRef = await FirebaseFirestore.instance
  //           .collection('Clients')
  //           .add(clientData);

  //       if (kDebugMode) {
  //         print('Nuevo cliente creado con ID: ${docRef.id}');
  //       }
  //     } else {
  //       // Actualizar cliente existente
  //       QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //           .collection('Clients')
  //           .where('Codigo', isEqualTo: existingClient.codigo)
  //           .limit(1)
  //           .get();

  //       if (querySnapshot.docs.isNotEmpty) {
  //         await querySnapshot.docs.first.reference.update(clientData);

  //         if (kDebugMode) {
  //           print('Cliente actualizado con código: ${existingClient.codigo}');
  //         }
  //       } else {
  //         throw Exception('No se encontró el cliente a actualizar');
  //       }
  //     }

  //     // Recargar la lista de clientes
  //     await _loadUsers();

  //     // Mostrar mensaje de éxito
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(existingClient == null
  //             ? 'Cliente creado exitosamente'
  //             : 'Cliente actualizado exitosamente'),
  //         backgroundColor: Colors.green,
  //       ),
  //     );
  //   } catch (e) {
  //     // Mostrar mensaje de error
  //     if (kDebugMode) {
  //       print('Error al guardar/actualizar cliente: $e');
  //     }
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Error: ${e.toString()}'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }

  Future<void> _saveOrUpdateClient(Clients? existingClient) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No hay ningún usuario logeado.');
      }

      final clientData = {
        'Nombre': _nombresController.text,
        'Apellidos': _apellidosController.text,
        'email': _emailController.text,
        'Telefono': _telefonoController.text,
        'Direccion': _direccionController.text,
        'Empresa': _empresaController.text,
        'CodVendedor': currentVendorCode,
        'UserId': user.uid,
        'updatedAt': Timestamp.now(),
      };

      if (existingClient == null) {
        clientData['Codigo'] = await _getNextClientCode();
        clientData['createdAt'] = Timestamp.now();
        await FirebaseFirestore.instance.collection('Clients').add(clientData);
      } else {
        await FirebaseFirestore.instance
            .collection('Clients')
            .where('Codigo', isEqualTo: existingClient.codigo)
            .limit(1)
            .get()
            .then((querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            return querySnapshot.docs.first.reference.update(clientData);
          } else {
            throw Exception('No se encontró el cliente a actualizar');
          }
        });
      }

      await _loadUsers();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(existingClient == null
              ? 'Cliente creado exitosamente'
              : 'Cliente actualizado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showFormDialog(BuildContext context, Clients? client) {
    final formKey = GlobalKey<FormState>();
    final ValueNotifier<bool> isEditable = ValueNotifier<bool>(client == null);

    if (client != null) {
      _nombresController.text = client.nombres;
      _apellidosController.text = client.apellidos;
      _emailController.text = client.email;
      _telefonoController.text = client.telefono;
      _codigoController.text = client.codigo;
      _direccionController.text = client.direccion;
      _empresaController.text = client.empresa;
      _fechaIngresoController.text =
          DateFormat('dd/MM/yyyy').format(client.fechaIngreso);
    } else {
      _nombresController.clear();
      _apellidosController.clear();
      _emailController.clear();
      _telefonoController.clear();
      _fechaIngresoController.text =
          DateFormat('dd/MM/yyyy').format(DateTime.now());
      _codigoController.clear();
      _direccionController.clear();
      _empresaController.clear();
      _codVendedorController.clear();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: LayoutBuilder(
            builder: (context, constraints) {
              double modalWidth = constraints.maxWidth > 600
                  ? constraints.maxWidth * 0.5
                  : constraints.maxWidth * 0.95;
              bool isLargeScreen = constraints.maxWidth > 600;

              return Container(
                width: modalWidth,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          client == null ? 'Nuevo Cliente' : 'Editar Cliente',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.black54),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Form(
                      key: formKey,
                      child: ValueListenableBuilder<bool>(
                        valueListenable: isEditable,
                        builder: (context, editable, _) {
                          return Column(
                            children: [
                              _buildResponsiveRow(isLargeScreen, [
                                _buildInputField(_nombresController, 'Nombres',
                                    enabled: editable),
                                _buildInputField(
                                    _apellidosController, 'Apellidos',
                                    enabled: editable),
                              ]),
                              _buildResponsiveRow(isLargeScreen, [
                                _buildInputField(_emailController, 'Email',
                                    isEmail: true, enabled: editable),
                                _buildInputField(
                                    _telefonoController, 'Teléfono',
                                    enabled: editable),
                              ]),
                              _buildResponsiveRow(isLargeScreen, [
                                _buildInputField(_empresaController, 'Empresa',
                                    enabled: editable),
                                _buildDatePicker(context,
                                    _fechaIngresoController, 'Fecha de Ingreso',
                                    enabled: editable),
                              ]),
                              _buildResponsiveRow(isLargeScreen, [
                                _buildInputField(
                                    _direccionController, 'Dirección',
                                    enabled: editable),
                              ])
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Botón de Editar solo se muestra cuando se está editando un cliente existente
                        if (client != null)
                          ElevatedButton(
                            onPressed: () {
                              isEditable.value = !isEditable.value;
                            },
                            child: ValueListenableBuilder<bool>(
                              valueListenable: isEditable,
                              builder: (context, editable, _) {
                                return Text(
                                  editable ? 'Cancelar Edición' : 'Editar',
                                );
                              },
                            ),
                          ),
                        const Spacer(),
                        // Botones de Cancelar y Guardar
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              _saveOrUpdateClient(client);
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text(
                            'Guardar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildResponsiveRow(bool isLargeScreen, List<Widget> children) {
    return isLargeScreen
        ? Row(
            children: children
                .map((child) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: child,
                      ),
                    ))
                .toList(),
          )
        : Column(children: children);
  }

  Widget _buildInputField(TextEditingController controller, String label,
      {bool isEmail = false, required bool enabled}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        enabled: enabled,
        controller: controller,
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
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingrese $label';
          }
          if (isEmail &&
              !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return 'Por favor ingrese un email válido';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDatePicker(
      BuildContext context, TextEditingController controller, String label,
      {required bool enabled}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        enabled: enabled,
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
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
          fillColor: Colors.grey[50], // Fondo claro como en los otros campos
          suffixIcon: const Icon(
            Icons.calendar_today_outlined, // Ícono más moderno
            color: Colors.indigo, // Cambiar color acorde a la paleta
          ),
        ),
        readOnly: true,
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
            builder: (BuildContext context, Widget? child) {
              return Theme(
                data: ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Colors.indigo, // Color del encabezado
                    onPrimary: Colors.white, // Color del texto del encabezado
                    onSurface: Colors.indigo, // Color del texto de los días
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.indigo,
                      backgroundColor:
                          Colors.transparent, // Color de los botones
                    ),
                  ),
                ),
                child: child!,
              );
            },
          );
          if (pickedDate != null) {
            String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
            controller.text = formattedDate;
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor seleccione una fecha';
          }
          return null;
        },
      ),
    );
  }

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
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Administrar Clientes'),
      // ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mis Clientes',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            // UserTable( clients: clients,
            //   onDelete: _deleteClient,
            //   onLoadUsers: _loadUsers,),
            //_buildUserTable(context) // Llama al widget desde el archivo externo
            Expanded(
              child: ResponsiveClientsTable(
                clientes: clients,
                deleteClient: (visita) => _deleteClient(visita),
                showClientVisitFormDialog: (context, visita) =>
                    _showFormDialog(context, visita),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildUserTable() {
  //   return Card(
  //     elevation: 4,
  //     color: Colors.white70,
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     child: Padding(
  //       padding: const EdgeInsets.all(16),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               const Text(
  //                 'Lista de Clientes',
  //                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
  //               ),
  //               ElevatedButton(
  //                 onPressed: () => _showFormDialog(context, null),
  //                 child: const Text('Nuevo Cliente'),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 16),
  //           clients.isEmpty
  //               ? const SizedBox(
  //                   height: 400,
  //                   child: Center(
  //                     child: CircularProgressIndicator(
  //                       strokeWidth: 2,
  //                     ), // Use a circular indicator
  //                   ),
  //                 )
  //               : SizedBox(
  //                   height: 400,
  //                   child: DataTable2(
  //                     columnSpacing: 12,
  //                     horizontalMargin: 12,
  //                     minWidth: 600,
  //                     decoration: BoxDecoration(
  //                       color: Colors.grey[100],
  //                       borderRadius: BorderRadius.circular(8),
  //                     ),
  //                     headingRowColor:
  //                         WidgetStateProperty.all(Colors.grey[200]),
  //                     columns: const [
  //                       DataColumn2(
  //                         label: Center(
  //                           child: Text('Nombres',
  //                               style: TextStyle(
  //                                 fontSize: 16,
  //                                 fontWeight: FontWeight.bold,
  //                                 color: Colors.blue,
  //                               )),
  //                         ),
  //                         size: ColumnSize.L,
  //                       ),
  //                       DataColumn2(
  //                         label: Center(
  //                           child: Text('Apellidos',
  //                               style: TextStyle(
  //                                 fontSize: 16,
  //                                 fontWeight: FontWeight.bold,
  //                                 color: Colors.blue,
  //                               )),
  //                         ),
  //                         size: ColumnSize.L,
  //                       ),
  //                       DataColumn2(
  //                         label: Center(
  //                           child: Text('Email',
  //                               style: TextStyle(
  //                                 fontSize: 16,
  //                                 fontWeight: FontWeight.bold,
  //                                 color: Colors.blue,
  //                               )),
  //                         ),
  //                         size: ColumnSize.L,
  //                       ),
  //                       DataColumn2(
  //                         label: Center(
  //                           child: Text('Teléfono',
  //                               style: TextStyle(
  //                                 fontSize: 16,
  //                                 fontWeight: FontWeight.bold,
  //                                 color: Colors.blue,
  //                               )),
  //                         ),
  //                         size: ColumnSize.L,
  //                       ),
  //                       DataColumn2(
  //                         label: Center(
  //                           child: Text('Empresa',
  //                               style: TextStyle(
  //                                 fontSize: 16,
  //                                 fontWeight: FontWeight.bold,
  //                                 color: Colors.blue,
  //                               )),
  //                         ),
  //                         size: ColumnSize.L,
  //                       ),
  //                       // DataColumn2(
  //                       //   label: Center(
  //                       //     child: Text('Direccion',
  //                       //         style: TextStyle(
  //                       //           fontSize: 16,
  //                       //           fontWeight: FontWeight.bold,
  //                       //           color: Colors.blue,
  //                       //         )),
  //                       //   ),
  //                       //   size: ColumnSize.L,
  //                       // ),
  //                       DataColumn2(
  //                         label: Center(
  //                           child: Text('Fecha Ingreso',
  //                               style: TextStyle(
  //                                 fontSize: 16,
  //                                 fontWeight: FontWeight.bold,
  //                                 color: Colors.blue,
  //                               )),
  //                         ),
  //                         size: ColumnSize.L,
  //                       ),
  //                     ],
  //                     rows: clients
  //                         .map((client) => DataRow2(
  //                               cells: [
  //                                 DataCell(Center(child: Text(client.nombres))),
  //                                 DataCell(
  //                                     Center(child: Text(client.apellidos))),
  //                                 DataCell(Center(child: Text(client.email))),
  //                                 DataCell(
  //                                     Center(child: Text(client.telefono))),
  //                                 DataCell(Center(child: Text(client.empresa))),
  //                                 // DataCell(
  //                                 //     Center(child: Text(client.direccion))),
  //                                 // ... (otras celdas) ...
  //                                 DataCell(
  //                                   Row(
  //                                     mainAxisAlignment:
  //                                         MainAxisAlignment.spaceBetween,
  //                                     children: [
  //                                       Text(DateFormat('dd/MM/yyyy')
  //                                           .format(client.fechaIngreso)),
  //                                       PopupMenuButton<String>(
  //                                         onSelected: (value) {
  //                                           if (value == 'Eliminar') {
  //                                             _deleteClient(client);
  //                                           } else if (value ==
  //                                               'Deshabilitar') {
  //                                             //_disableEmployee(employee);
  //                                             print(
  //                                                 'Aqui se va a deshabilitar');
  //                                           }
  //                                         },
  //                                         itemBuilder: (BuildContext context) =>
  //                                             [
  //                                           const PopupMenuItem<String>(
  //                                             value: 'Eliminar',
  //                                             child: Text('Eliminar'),
  //                                           ),
  //                                           const PopupMenuItem<String>(
  //                                             value: 'Deshabilitar',
  //                                             child: Text('Deshabilitar'),
  //                                           ),
  //                                         ],
  //                                         icon: const Icon(Icons.more_vert),
  //                                       ),
  //                                     ],
  //                                   ),
  //                                 ),
  //                               ],
  //                               color: WidgetStateProperty.resolveWith<Color?>(
  //                                 (Set<WidgetState> states) {
  //                                   if (states.contains(WidgetState.hovered)) {
  //                                     return Colors.grey[300];
  //                                   }
  //                                   return null;
  //                                 },
  //                               ),
  //                               onDoubleTap: () =>
  //                                   _showFormDialog(context, client),
  //                             ))
  //                         .toList(),
  //                   ),
  //                 ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildUserTable(BuildContext context) {
  //   return LayoutBuilder(
  //     builder: (context, constraints) {
  //       final isSmallScreen = constraints.maxWidth < 600;

  //       return Card(
  //         elevation: 4,
  //         color: Colors.white70,
  //         shape:
  //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //         child: Padding(
  //           padding: const EdgeInsets.all(16),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   const Text(
  //                     'Lista de Clientes',
  //                     style:
  //                         TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
  //                   ),
  //                   ElevatedButton(
  //                     onPressed: () => _showFormDialog(context, null),
  //                     child: const Text('Nuevo Cliente'),
  //                   ),
  //                 ],
  //               ),
  //               const SizedBox(height: 16),
  //               clients.isEmpty
  //                   ? SizedBox(
  //                       height: 400,
  //                       child: FutureBuilder(
  //                         future: Future.delayed(const Duration(seconds: 1)),
  //                         builder: (context, snapshot) {
  //                           if (snapshot.connectionState ==
  //                               ConnectionState.waiting) {
  //                             return const Center(
  //                               child:
  //                                   CircularProgressIndicator(strokeWidth: 2),
  //                             );
  //                           } else {
  //                             return const Center(
  //                               child: Text(
  //                                 "No hay clientes para mostrar",
  //                                 style: TextStyle(fontSize: 18),
  //                               ),
  //                             );
  //                           }
  //                         },
  //                       ),
  //                     )
  //                   : SizedBox(
  //                       height: 400,
  //                       child: DataTable2(
  //                         columnSpacing: 12,
  //                         horizontalMargin: 12,
  //                         minWidth: isSmallScreen ? 400 : 600,
  //                         decoration: BoxDecoration(
  //                           color: Colors.grey[100],
  //                           borderRadius: BorderRadius.circular(8),
  //                         ),
  //                         headingRowColor:
  //                             WidgetStateProperty.all(Colors.grey[200]),
  //                         columns: _buildColumns(isSmallScreen),
  //                         rows: _buildRows(isSmallScreen),
  //                       ),
  //                     ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  // List<DataColumn2> _buildColumns(bool isSmallScreen) {
  //   final List<DataColumn2> baseColumns = [
  //     const DataColumn2(
  //       label: Center(
  //         child: Text('Nombres',
  //             style: TextStyle(
  //               fontSize: 16,
  //               fontWeight: FontWeight.bold,
  //               color: Colors.blue,
  //             )),
  //       ),
  //       size: ColumnSize.L,
  //     ),
  //     const DataColumn2(
  //       label: Center(
  //         child: Text('Apellidos',
  //             style: TextStyle(
  //               fontSize: 16,
  //               fontWeight: FontWeight.bold,
  //               color: Colors.blue,
  //             )),
  //       ),
  //       size: ColumnSize.L,
  //     ),
  //     const DataColumn2(
  //       label: Center(
  //         child: Text('Empresa',
  //             style: TextStyle(
  //               fontSize: 16,
  //               fontWeight: FontWeight.bold,
  //               color: Colors.blue,
  //             )),
  //       ),
  //       size: ColumnSize.L,
  //     ),
  //     const DataColumn2(
  //       label: Center(
  //         child: Text('Fecha Ingreso',
  //             style: TextStyle(
  //               fontSize: 16,
  //               fontWeight: FontWeight.bold,
  //               color: Colors.blue,
  //             )),
  //       ),
  //       size: ColumnSize.L,
  //     ),
  //   ];

  //   if (!isSmallScreen) {
  //     baseColumns.insert(
  //         2,
  //         const DataColumn2(
  //           label: Center(
  //             child: Text('Email',
  //                 style: TextStyle(
  //                   fontSize: 16,
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.blue,
  //                 )),
  //           ),
  //           size: ColumnSize.L,
  //         ));
  //     baseColumns.insert(
  //         3,
  //         const DataColumn2(
  //           label: Center(
  //             child: Text('Teléfono',
  //                 style: TextStyle(
  //                   fontSize: 16,
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.blue,
  //                 )),
  //           ),
  //           size: ColumnSize.L,
  //         ));
  //   }

  //   return baseColumns;
  // }

  // List<DataRow2> _buildRows(bool isSmallScreen) {
  //   return clients.map((client) {
  //     final List<DataCell> baseCells = [
  //       DataCell(Center(child: Text(client.nombres))),
  //       DataCell(Center(child: Text(client.apellidos))),
  //       DataCell(Center(child: Text(client.empresa))),
  //       DataCell(
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Text(DateFormat('dd/MM/yyyy').format(client.fechaIngreso)),
  //             PopupMenuButton<String>(
  //               onSelected: (value) {
  //                 if (value == 'Eliminar') {
  //                   _deleteClient(client);
  //                 } else if (value == 'Deshabilitar') {
  //                   print('Aqui se va a deshabilitar');
  //                 }
  //               },
  //               itemBuilder: (BuildContext context) => [
  //                 const PopupMenuItem<String>(
  //                   value: 'Eliminar',
  //                   child: Text('Eliminar'),
  //                 ),
  //                 const PopupMenuItem<String>(
  //                   value: 'Deshabilitar',
  //                   child: Text('Deshabilitar'),
  //                 ),
  //               ],
  //               icon: const Icon(Icons.more_vert),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ];

  //     if (!isSmallScreen) {
  //       baseCells.insert(2, DataCell(Center(child: Text(client.email))));
  //       baseCells.insert(3, DataCell(Center(child: Text(client.telefono))));
  //     }

  //     return DataRow2(
  //       cells: baseCells,
  //       color: WidgetStateProperty.resolveWith<Color?>(
  //         (Set<WidgetState> states) {
  //           if (states.contains(WidgetState.hovered)) {
  //             return Colors.grey[300];
  //           }
  //           return null;
  //         },
  //       ),
  //       onDoubleTap: () => _showFormDialog(context, client),
  //     );
  //   }).toList();
  // }

  void _deleteClient(Clients client) async {
    // Mostrar un diálogo de confirmación
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            width: 400, // Ajusta el tamaño según tu diseño
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Confirmar eliminación',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '¿Está seguro de que desea eliminar a ${client.nombres} ${client.apellidos}?',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.red, // Color del botón "Guardar"
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      child: const Text('Eliminar',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmDelete == true) {
      try {
        // Buscar el documento por el email del empleado
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('Clients')
            .where('Codigo', isEqualTo: client.codigo)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Eliminar el documento
          await querySnapshot.docs.first.reference.delete();

          // Actualizar la lista de empleados
          setState(() {
            clients.removeWhere((e) => e.codigo == client.codigo);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cliente eliminado con éxito')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se encontró el cliente')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar el cliente: $e')),
        );
      }
    }
  }
}
