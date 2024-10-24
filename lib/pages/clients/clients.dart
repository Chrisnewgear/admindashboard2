import 'dart:math';
import 'package:admindashboard/models/clients.dart';
import 'package:admindashboard/pages/clients/widgets/clients_paginated_table.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  bool isLoading = false;
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
        clients = querySnapshot.docs
            .map((doc) => Clients.fromFirestore(doc))
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
      _codigoController.clear();
      _direccionController.clear();
      _empresaController.clear();
      _codVendedorController.clear();
      _fechaIngresoController.text =
          DateFormat('dd/MM/yyyy').format(DateTime.now());
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
              double modalWidth;
              if (constraints.maxWidth > 1024) {
                modalWidth = constraints.maxWidth * 0.5;
              } else if (constraints.maxWidth > 768) {
                modalWidth = constraints.maxWidth * 0.7;
              } else {
                modalWidth = constraints.maxWidth * 0.9;
              }

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
                          bool isLargeScreen = constraints.maxWidth > 986;
                          return Column(
                            children: [
                              _buildResponsiveRow(isLargeScreen, [
                                _buildInputField(_nombresController, 'Nombres*',
                                    enabled: editable),
                                _buildInputField(
                                    _apellidosController, 'Apellidos*',
                                    enabled: editable),
                              ]),
                              _buildResponsiveRow(isLargeScreen, [
                                _buildInputField(_emailController, 'Email',
                                    isEmail: true, enabled: editable),
                                _buildInputField(
                                    _telefonoController, 'Teléfono*',
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
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (client != null)
                          Flexible(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width < 768
                                        ? double.infinity
                                        : 200,
                              ),
                              child: ValueListenableBuilder<bool>(
                                valueListenable: isEditable,
                                builder: (context, editable, _) {
                                  return ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        horizontal:
                                            MediaQuery.of(context).size.width <
                                                    768
                                                ? 12
                                                : 16,
                                        vertical: 12,
                                      ),
                                    ),
                                    onPressed: () {
                                      isEditable.value = !isEditable.value;
                                    },
                                    icon: editable
                                        ? const Icon(Icons.edit_off)
                                        : const Icon(Icons.edit),
                                    label:
                                        MediaQuery.of(context).size.width < 768
                                            ? const SizedBox.shrink()
                                            : Text(editable
                                                ? 'Cancelar Edición'
                                                : 'Editar'),
                                  );
                                },
                              ),
                            ),
                          ),
                        if (client != null) const SizedBox(width: 8),
                        Flexible(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width < 768
                                  ? double.infinity
                                  : 200,
                            ),
                            child: TextButton.icon(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.cancel),
                              label: MediaQuery.of(context).size.width < 768
                                  ? const SizedBox.shrink()
                                  : const Text('Cancelar'),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width < 768
                                          ? 12
                                          : 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width < 768
                                  ? double.infinity
                                  : 200,
                            ),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width < 768
                                          ? 12
                                          : 16,
                                  vertical: 12,
                                ),
                              ),
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  _saveOrUpdateClient(client);
                                  Navigator.of(context).pop();
                                }
                              },
                              icon: const Icon(
                                Icons.save,
                                color: Colors.white,
                              ),
                              label: MediaQuery.of(context).size.width < 768
                                  ? const SizedBox.shrink()
                                  : const Text(
                                      'Guardar',
                                      style: TextStyle(color: Colors.white),
                                    ),
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

  // Widget _buildInputField(TextEditingController controller, String label,
  //     {bool isEmail = false, required bool enabled}) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 16),
  //     child: TextFormField(
  //       enabled: enabled,
  //       controller: controller,
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
      {bool isEmail = false, required bool enabled}) {
    // Check if the field requires validation
    bool requiresValidation =
        label == 'Nombres*' || label == 'Apellidos*' || label == 'Teléfono*';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        enabled: enabled,
        controller: controller,
        decoration: InputDecoration(
          labelText: requiresValidation ? label : label.replaceAll('*', ''),
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
          // Only validate required fields
          if (requiresValidation) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingrese ${label.replaceAll('*', '')}';
            }
          }
          // Email validation is optional now
          if (isEmail &&
              value!.isNotEmpty &&
              !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return 'Por favor ingrese un email válido';
          }
          return null;
        },
      ),
    );
  }

  // Widget _buildDatePicker(
  //     BuildContext context, TextEditingController controller, String label,
  //     {required bool enabled}) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 16),
  //     child: TextFormField(
  //       enabled: enabled,
  //       controller: controller,
  //       decoration: InputDecoration(
  //         labelText: label,
  //         labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
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
  //         fillColor: Colors.grey[50], // Fondo claro como en los otros campos
  //         suffixIcon: const Icon(
  //           Icons.calendar_today_outlined, // Ícono más moderno
  //           color: Colors.indigo, // Cambiar color acorde a la paleta
  //         ),
  //       ),
  //       readOnly: true,
  //       onTap: () async {
  //         DateTime? pickedDate = await showDatePicker(
  //           context: context,
  //           initialDate: DateTime.now(),
  //           firstDate: DateTime(2000),
  //           lastDate: DateTime(2101),
  //           builder: (BuildContext context, Widget? child) {
  //             return Theme(
  //               data: ThemeData.light().copyWith(
  //                 colorScheme: const ColorScheme.light(
  //                   primary: Colors.indigo, // Color del encabezado
  //                   onPrimary: Colors.white, // Color del texto del encabezado
  //                   onSurface: Colors.indigo, // Color del texto de los días
  //                 ),
  //                 textButtonTheme: TextButtonThemeData(
  //                   style: TextButton.styleFrom(
  //                     foregroundColor: Colors.indigo,
  //                     backgroundColor:
  //                         Colors.transparent, // Color de los botones
  //                   ),
  //                 ),
  //               ),
  //               child: child!,
  //             );
  //           },
  //         );
  //         if (pickedDate != null) {
  //           String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
  //           controller.text = formattedDate;
  //         }
  //       },
  //       validator: (value) {
  //         if (value == null || value.isEmpty) {
  //           return 'Por favor seleccione una fecha';
  //         }
  //         return null;
  //       },
  //     ),
  //   );
  // }

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
          fillColor: Colors.grey[50],
          suffixIcon: const Icon(
            Icons.calendar_today_outlined,
            color: Colors.indigo,
          ),
        ),
        readOnly: true,
        onTap: enabled
            ? () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                  builder: (BuildContext context, Widget? child) {
                    return Theme(
                      data: ThemeData.light().copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Colors.indigo,
                          onPrimary: Colors.white,
                          onSurface: Colors.indigo,
                        ),
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.indigo,
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (pickedDate != null) {
                  String formattedDate =
                      DateFormat('dd/MM/yyyy').format(pickedDate);
                  controller.text = formattedDate;
                }
              }
            : null,
        // Remove validation for date picker
        validator: null,
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
      body: Padding(
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
                isLoading: isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
