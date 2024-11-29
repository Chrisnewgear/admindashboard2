import 'dart:math';
import 'package:admindashboard/models/usuarios.dart';
import 'package:admindashboard/pages/roles/Widgets/role_paginated_table.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class RoleManagementWidget extends StatefulWidget {
  const RoleManagementWidget({super.key});

  @override
  RoleManagementWidgetState createState() => RoleManagementWidgetState();
}

class RoleManagementWidgetState extends State<RoleManagementWidget> {
  //final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String selectedRole = 'Vendedor';
  List<String> roles = ['Vendedor', 'Supervisor', 'Admin', 'None'];
  List<Usuario> employees = [];

  final TextEditingController _nombresController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _fechaIngresoController = TextEditingController();
  final TextEditingController _codigoController = TextEditingController();
  bool _asignadoController = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      isLoading = true; // Activar loading al inicio de la carga
    });

    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('Users').get();
      setState(() {
        employees = querySnapshot.docs
            .map((doc) => Usuario.fromFirestore(doc))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false; // Desactivar loading incluso si hay error
      });

      if (kDebugMode) {
        print('Error loading users: $e');
      }
      // Puedes mostrar un mensaje de error al usuario si lo deseas
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar los usuarios: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String> _getNextUserCode() async {
    Random random = Random();
    String code = '';
    bool isUnique = false;

    while (!isUnique) {
      // Generar un número aleatorio de 6 dígitos
      int randomNumber = random.nextInt(900000) + 100000; // Asegura 6 dígitos
      code = 'USR$randomNumber';

      // Verificar si el código ya existe en Firebase
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('Codigo', isEqualTo: code)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        isUnique = true; // El código es único
      }
    }

    return code;
  }

  // Future<void> _saveOrUpdateEmployee(
  //     Usuario? existingEmployee, List<Usuario> selectedUsers) async {
  //   try {
  //     final employeeData = {
  //       'Nombre': _nombresController.text,
  //       'Apellidos': _apellidosController.text,
  //       'email': _emailController.text,
  //       'Telefono': _telefonoController.text,
  //       'Role': selectedRole,
  //       'Codigo': _codigoController.text,
  //       'updatedAt': Timestamp.now(),
  //     };

  //     // Si el rol es 'Vendedor', agregar el campo 'Asignado' con valor predeterminado 'false'
  //     if (selectedRole == 'Vendedor') {
  //       employeeData['Asignado'] = false;
  //     }

  //     // Convertir la lista de usuarios seleccionados a un formato compatible con Firebase
  //     final selectedUsersData =
  //         selectedUsers.map((user) => user.toMap()).toList();

  //     if (existingEmployee == null) {
  //       // Crear un nuevo empleado
  //       final nextCode = await _getNextUserCode();
  //       employeeData['Codigo'] = nextCode;
  //       employeeData['createdAt'] = Timestamp.now();

  //       // Crear el nuevo documento del empleado en la colección 'Users'
  //       await FirebaseFirestore.instance.collection('Users').add(employeeData);
  //     } else {
  //       // Actualizar el empleado existente
  //       // Primero, encontramos el documento basado en el 'Codigo' del empleado
  //       final userQuerySnapshot = await FirebaseFirestore.instance
  //           .collection('Users')
  //           .where('Codigo', isEqualTo: existingEmployee.codigo)
  //           .limit(1)
  //           .get();

  //       if (userQuerySnapshot.docs.isNotEmpty) {
  //         final userDoc = userQuerySnapshot.docs.first.reference;

  //         // Actualizar los datos principales del empleado
  //         await userDoc.update(employeeData);

  //         // Actualizar o agregar el campo 'MyTeam' en el documento del empleado
  //         await userDoc.update({
  //           'MyTeam':
  //               selectedUsersData, // Guardamos la lista de usuarios en el campo 'MyTeam'
  //         });
  //       }
  //     }

  //     // Recargar la lista de usuarios
  //     await _loadUsers();

  //     // Mostrar un mensaje de éxito
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(existingEmployee == null
  //             ? 'Empleado creado exitosamente'
  //             : 'Empleado actualizado exitosamente'),
  //         backgroundColor: Colors.green,
  //       ),
  //     );
  //   } catch (e) {
  //     // Mostrar mensaje de error
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Error: ${e.toString()}'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }

  Future<void> _saveOrUpdateEmployee(
      Usuario? existingEmployee, List<Usuario> selectedUsers) async {
    try {
      final employeeData = {
        'Nombre': _nombresController.text,
        'Apellidos': _apellidosController.text,
        'email': _emailController.text,
        'Telefono': _telefonoController.text,
        'Role': selectedRole,
        'Codigo': _codigoController.text,
        'Asignado': _asignadoController,
        'updatedAt': Timestamp.now(),
      };

      // Add 'Assigned' field for 'Vendedor' role
      if (selectedRole == 'Vendedor') {
        employeeData['Asignado'] = false;
        //employeeData['Asignado'] = existingEmployee != null ? true : false;
      }

      final selectedUsersData =
          selectedUsers.map((user) => user.toMap()).toList();

      if (existingEmployee == null) {
        final nextCode = await _getNextUserCode();
        employeeData['Codigo'] = nextCode;
        employeeData['createdAt'] = Timestamp.now();

        await FirebaseFirestore.instance.collection('Users').add(employeeData);
      } else {
        final userQuerySnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .where('Codigo', isEqualTo: existingEmployee.codigo)
            .limit(1)
            .get();

        if (userQuerySnapshot.docs.isNotEmpty) {
          final userDoc = userQuerySnapshot.docs.first.reference;

          await userDoc.update(employeeData);

          await userDoc.update({
            'MyTeam': selectedUsersData,
          });
        }
      }

      // selectedUsersData.forEach((userData) async {
      //   final userQuerySnapshot = await FirebaseFirestore.instance
      //       .collection('Users')
      //       .where('Codigo', isEqualTo: userData['Codigo'])
      //       .limit(1)
      //       .get();

      //       if(userQuerySnapshot.docs.isNotEmpty){
      //         _asignadoController = true;
      //       }
      // });

      for (var userData in selectedUsersData) {
        final userQuerySnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .where('Codigo', isEqualTo: userData['Codigo'])
            .limit(1)
            .get();

        if (userQuerySnapshot.docs.isNotEmpty) {
          _asignadoController = true;
        }
      }

      if (_asignadoController) {
        employeeData['CodSupervisor'] = existingEmployee?.codigo ?? '';
      } else {
        employeeData['CodSupervisor'] = '';
      }

      await _loadUsers();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(existingEmployee == null
              ? 'Empleado creado exitosamente'
              : 'Empleado actualizado exitosamente'),
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

  Future<void> _showFormDialog(BuildContext context, Usuario? employee) async {
    final formKey = GlobalKey<FormState>();
    final ValueNotifier<bool> isEditable =
        ValueNotifier<bool>(employee == null);
    final TextEditingController searchController = TextEditingController();
    final ValueNotifier<String> searchQuery = ValueNotifier<String>('');
    final ValueNotifier<List<Usuario>> selectedVendedoresNotifier =
        ValueNotifier<List<Usuario>>([]);

    if (employee != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .where('Codigo', isEqualTo: employee.codigo)
          .limit(1)
          .get()
          .then((snapshot) => snapshot.docs.first);

      final myTeam = (userDoc.data()['MyTeam'] as List<dynamic>?)
              ?.map((item) => Usuario.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [];

      selectedVendedoresNotifier.value = myTeam;

      _nombresController.text = employee.nombres;
      _apellidosController.text = employee.apellidos;
      _emailController.text = employee.email;
      _telefonoController.text = employee.telefono;
      _codigoController.text = employee.codigo;
      _fechaIngresoController.text =
          DateFormat('dd/MM/yyyy').format(employee.fechaIngreso);
      _asignadoController = employee.asignado;
      selectedRole = employee.role;
    } else {
      _nombresController.clear();
      _apellidosController.clear();
      _emailController.clear();
      _telefonoController.clear();
      _fechaIngresoController.clear();
      _codigoController.clear();
      _asignadoController = false;
      selectedRole = 'Vendedor';
    }

    Future<List<Usuario>> fetchVendedores() async {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('Role', isEqualTo: 'Vendedor')
          .get();
      return snapshot.docs.map((doc) => Usuario.fromFirestore(doc)).toList();
    }

    void toggleSelection(Usuario vendedor) {
      final currentSelected = selectedVendedoresNotifier.value;
      if (currentSelected.contains(vendedor)) {
        selectedVendedoresNotifier.value =
            currentSelected.where((v) => v != vendedor).toList();
      } else {
        selectedVendedoresNotifier.value = [...currentSelected, vendedor];
      }
    }

    bool matchesSearchQuery(Usuario vendedor, String query) {
      final fullName =
          '${vendedor.nombres} ${vendedor.apellidos}'.toLowerCase();
      final codigo = vendedor.codigo.toLowerCase();
      query = query.toLowerCase().trim();
      return fullName.contains(query) || codigo.contains(query);
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
              double modalWidth = constraints.maxWidth > 1024
                  ? constraints.maxWidth * 0.5
                  : constraints.maxWidth > 768
                      ? constraints.maxWidth * 0.7
                      : constraints.maxWidth * 0.9;

              return Container(
                width: modalWidth,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Nuevo Rol',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          IconButton(
                            icon:
                                const Icon(Icons.close, color: Colors.black54),
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
                                  _buildInputField(
                                      _nombresController, 'Nombres'),
                                  _buildInputField(
                                      _apellidosController, 'Apellidos'),
                                ]),
                                _buildResponsiveRow(isLargeScreen, [
                                  _buildInputField(_emailController, 'Email',
                                      isEmail: true),
                                  _buildInputField(
                                      _telefonoController, 'Teléfono'),
                                ]),
                                _buildResponsiveRow(isLargeScreen, [
                                  _buildDropdown(
                                    selectedRole,
                                    (String? newValue) {
                                      setState(() {
                                        selectedRole = newValue!;
                                      });
                                    },
                                  ),
                                  _buildDatePicker(
                                      context,
                                      _fechaIngresoController,
                                      'Fecha de Ingreso'),
                                ]),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Conditionally render vendor selection ONLY for Supervisor role
                      if (selectedRole == 'Supervisor') ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            "Lista de Vendedores",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        TextField(
                          controller: searchController,
                          onChanged: (value) => searchQuery.value = value,
                          decoration: InputDecoration(
                            labelText: 'Buscar vendedor',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                searchController.clear();
                                searchQuery.value = '';
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FutureBuilder<List<Usuario>>(
                          future: fetchVendedores(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return const Text(
                                  'No se encontraron vendedores.');
                            } else {
                              List<Usuario> vendedores = snapshot.data!;
                              vendedores.sort(
                                  (a, b) => a.nombres.compareTo(b.nombres));

                              return ValueListenableBuilder<String>(
                                valueListenable: searchQuery,
                                builder: (context, query, _) {
                                  List<Usuario> filteredVendedores = vendedores
                                      .where((vendedor) =>
                                          matchesSearchQuery(vendedor, query))
                                      .toList();

                                  return ValueListenableBuilder<List<Usuario>>(
                                    valueListenable: selectedVendedoresNotifier,
                                    builder: (context, selectedVendedores, _) {
                                      return SizedBox(
                                        height: 200,
                                        child: filteredVendedores.isEmpty
                                            ? const Center(
                                                child: Text(
                                                    'No se encontraron vendedores'))
                                            : ListView.builder(
                                                shrinkWrap: true,
                                                itemCount:
                                                    filteredVendedores.length,
                                                itemBuilder: (context, index) {
                                                  final vendedor =
                                                      filteredVendedores[index];
                                                  bool isSelected =
                                                      selectedVendedores
                                                          .contains(vendedor);
                                                  return Container(
                                                    margin: const EdgeInsets
                                                        .symmetric(vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[100],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      border: Border.all(
                                                          color: Colors
                                                              .grey.shade300),
                                                    ),
                                                    child: ListTile(
                                                      leading: const Icon(
                                                          Icons.person,
                                                          color: Colors.indigo),
                                                      title: Text(
                                                        '${vendedor.nombres} ${vendedor.apellidos}',
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                      trailing: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            vendedor.codigo,
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .indigo
                                                                  .shade700,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Checkbox(
                                                            value: isSelected,
                                                            onChanged:
                                                                (bool? value) {
                                                              toggleSelection(
                                                                  vendedor);
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                      );
                                    },
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Flexible(
                            child: TextButton.icon(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.cancel),
                              label: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  // Asegúrate de que estamos pasando los parámetros correctos
                                  _saveOrUpdateEmployee(
                                    employee!, // Asegúrate de que no sea null
                                    selectedVendedoresNotifier.value,
                                  );
                                  Navigator.of(context).pop();
                                }
                              },
                              icon: const Icon(Icons.save),
                              label: const Text('Guardar'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _fechaIngresoController.dispose();
    _codigoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Administrar Roles'),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Administrar Roles',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ResponsiveRolesTable(
                usuarios: employees,
                deleteUsuario: (employee) => _deleteEmployee(employee),
                showUsuarioFormDialog: (context, employee) =>
                    _showFormDialog(context, employee),
                isLoading: isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteEmployee(Usuario employee) async {
    try {
      // Find the user document by email
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: employee.email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Delete the document
        await querySnapshot.docs.first.reference.delete();

        // Update the employee list in the UI
        setState(() {
          employees.removeWhere((e) => e.email == employee.email);
        });

        // Reload users if necessary
        await _loadUsers();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Empleado eliminado con éxito')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontró el empleado')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el empleado: $e')),
      );
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

  Widget _buildDropdown(String currentValue, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: currentValue,
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
            return 'Por favor seleccione un role';
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
}
