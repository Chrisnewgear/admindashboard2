// ignore_for_file: duplicate_import

import 'dart:math';

import 'package:admindashboard/models/clients.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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
          setState(() {
            _codVendedorController.text = userDoc.get('Codigo') ?? '';
          });
        }
      }

      // Load visits
      await _loadUsers();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user code and visits: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Error al cargar información del usuario y visitas: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadUsers() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('Clients').get();
      setState(() {
        clients = querySnapshot.docs
            .map((doc) => Clients.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading clients: $e');
      }
      // Puedes mostrar un mensaje de error al usuario si lo deseas
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
      final clientData = {
        'Nombre': _nombresController.text,
        'Apellidos': _apellidosController.text,
        'email': _emailController.text,
        'Telefono': _telefonoController.text,
        'Direccion': _direccionController.text,
        'Empresa': _empresaController.text,
        'Codigo': _codigoController.text,
        'CodVendedor': _codVendedorController.text,
        'updatedAt': Timestamp.now(),
      };

      if (existingClient == null) {
        // Create a new employee
        final nextCode = await _getNextClientCode();
        clientData['Codigo'] = nextCode;
        clientData['createdAt'] = Timestamp.now();
        await FirebaseFirestore.instance.collection('Clients').add(clientData);
      } else {
        // Update existing employee
        await FirebaseFirestore.instance
            .collection('Clients')
            .where('Codigo', isEqualTo: existingClient.codigo)
            .get()
            .then((querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            querySnapshot.docs.first.reference.update(clientData);
          }
        });
      }

      // Reload the users list
      await _loadUsers();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(existingClient == null
              ? 'Cliente creado exitosamente'
              : 'Cliente actualizado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showFormDialog(BuildContext context, Clients? client) {
    final _formKey = GlobalKey<FormState>();

    if (client != null) {
      _nombresController.text = client.nombres;
      _apellidosController.text = client.apellidos;
      _emailController.text = client.email;
      _telefonoController.text = client.telefono;
      _codigoController.text = client.codigo;
      _direccionController.text = client.direccion;
      _codVendedorController.text = client.codVendedor;
      _empresaController.text = client.empresa;
      _fechaIngresoController.text =
          DateFormat('dd/MM/yyyy').format(client.fechaIngreso);
    } else {
      _nombresController.clear();
      _apellidosController.clear();
      _emailController.clear();
      _telefonoController.clear();
      _fechaIngresoController.clear();
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
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildResponsiveRow(isLargeScreen, [
                            _buildInputField(_nombresController, 'Nombres'),
                            _buildInputField(_apellidosController, 'Apellidos'),
                          ]),
                          _buildResponsiveRow(isLargeScreen, [
                            _buildInputField(_emailController, 'Email',
                                isEmail: true),
                            _buildInputField(_telefonoController, 'Teléfono'),
                          ]),
                          _buildResponsiveRow(isLargeScreen, [
                            _buildInputField(_empresaController, 'Empresa'),
                            _buildDatePicker(context, _fechaIngresoController,
                                'Fecha de Ingreso'),
                          ]),
                          _buildInputField(_direccionController, 'Dirección'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
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
                            if (_formKey.currentState!.validate()) {
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
      {bool isEmail = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
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
            borderSide: BorderSide(color: Colors.indigo),
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
      BuildContext context, TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
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
            borderSide: BorderSide(color: Colors.indigo),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          suffixIcon: Icon(Icons.calendar_today, color: Colors.grey[600]),
        ),
        readOnly: true,
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
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
            _buildUserTable() // Llama al widget desde el archivo externo
          ],
        ),
      ),
    );
  }

  Widget _buildUserTable() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Lista de Clientes',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () => _showFormDialog(context, null),
                  child: const Text('Nuevo Cliente'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            clients.isEmpty
                ? const SizedBox(
                    height: 400,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ), // Use a circular indicator
                    ),
                  )
                : SizedBox(
                    height: 400,
                    child: DataTable2(
                      columnSpacing: 12,
                      horizontalMargin: 12,
                      minWidth: 600,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      headingRowColor:
                          WidgetStateProperty.all(Colors.grey[200]),
                      columns: const [
                        DataColumn2(
                          label: Center(
                            child: Text('Codigo',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                )),
                          ),
                          size: ColumnSize.L,
                        ),
                        DataColumn2(
                          label: Center(
                            child: Text('Cod. Vendedor',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                )),
                          ),
                          size: ColumnSize.L,
                        ),
                        DataColumn2(
                          label: Center(
                            child: Text('Nombres',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                )),
                          ),
                          size: ColumnSize.L,
                        ),
                        DataColumn2(
                          label: Center(
                            child: Text('Apellidos',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                )),
                          ),
                          size: ColumnSize.L,
                        ),
                        DataColumn2(
                          label: Center(
                            child: Text('Email',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                )),
                          ),
                          size: ColumnSize.L,
                        ),
                        DataColumn2(
                          label: Center(
                            child: Text('Teléfono',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                )),
                          ),
                          size: ColumnSize.L,
                        ),
                        DataColumn2(
                          label: Center(
                            child: Text('Empresa',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                )),
                          ),
                          size: ColumnSize.L,
                        ),
                        DataColumn2(
                          label: Center(
                            child: Text('Direccion',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                )),
                          ),
                          size: ColumnSize.L,
                        ),
                        DataColumn2(
                          label: Center(
                            child: Text('Fecha Ingreso',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                )),
                          ),
                          size: ColumnSize.L,
                        ),
                      ],
                      rows: clients
                          .map((client) => DataRow2(
                                cells: [
                                  DataCell(Center(child: Text(client.codigo))),
                                  DataCell(Center(child: Text(client.codVendedor))),
                                  DataCell(Center(child: Text(client.nombres))),
                                  DataCell(Center(child: Text(client.apellidos))),
                                  DataCell(Center(child: Text(client.email))),
                                  DataCell(Center(child: Text(client.telefono))),
                                  DataCell(Center(child: Text(client.empresa))),
                                  DataCell(Center(child: Text(client.direccion))),
                                  // ... (otras celdas) ...
                                  DataCell(
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(DateFormat('dd/MM/yyyy')
                                            .format(client.fechaIngreso)),
                                        PopupMenuButton<String>(
                                          onSelected: (value) {
                                            if (value == 'Eliminar') {
                                              _deleteClient(client);
                                            } else if (value ==
                                                'Deshabilitar') {
                                              //_disableEmployee(employee);
                                              print(
                                                  'Aqui se va a deshabilitar');
                                            }
                                          },
                                          itemBuilder: (BuildContext context) =>
                                              [
                                            const PopupMenuItem<String>(
                                              value: 'Eliminar',
                                              child: Text('Eliminar'),
                                            ),
                                            const PopupMenuItem<String>(
                                              value: 'Deshabilitar',
                                              child: Text('Deshabilitar'),
                                            ),
                                          ],
                                          icon: const Icon(Icons.more_vert),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                color: WidgetStateProperty.resolveWith<Color?>(
                                  (Set<WidgetState> states) {
                                    if (states.contains(WidgetState.hovered)) {
                                      return Colors.grey[300];
                                    }
                                    return null;
                                  },
                                ),
                                onDoubleTap: () =>
                                    _showFormDialog(context, client),
                              ))
                          .toList(),
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
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text(
              '¿Está seguro de que desea eliminar a ${client.nombres} ${client.apellidos}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Eliminar'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
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

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.black87;
      case 'supervisor':
        return Colors.green[400]!;
      case 'vendedor':
        return Colors.blue[300]!;
      default:
        return Colors.grey[400]!;
    }
  }

  Widget _buildDropdown(String selectedRole, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedRole,
      items: ['Vendedor', 'Supervisor', 'Admin', 'None'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: 'Role',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }

  // Widget _buildDatePicker(
  //     BuildContext context, TextEditingController controller) {
  //   return TextFormField(
  //     controller: controller,
  //     decoration: InputDecoration(
  //       labelText: 'Fecha Ingreso',
  //       border: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(10),
  //       ),
  //       filled: true,
  //       fillColor: Colors.grey[100],
  //       suffixIcon: const Icon(Icons.calendar_today),
  //     ),
  //     onTap: () async {
  //       DateTime? pickedDate = await showDatePicker(
  //         context: context,
  //         initialDate: DateTime.now(),
  //         firstDate: DateTime(2000),
  //         lastDate: DateTime(2101),
  //       );
  //       if (pickedDate != null) {
  //         String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
  //         controller.text = formattedDate;
  //       }
  //     },
  //     readOnly: true,
  //   );
  // }
}
