import 'dart:math';
import 'package:admindashboard/models/usuarios.dart';
import 'package:admindashboard/pages/roles/Widgets/role_paginated_table.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  // Future<void> _saveOrUpdateEmployee(Usuario? existingEmployee) async {
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

  //     if (existingEmployee == null) {
  //       // Create a new employee
  //       final nextCode = await _getNextUserCode();
  //       employeeData['Codigo'] = nextCode;
  //       employeeData['createdAt'] = Timestamp.now();

  //       await FirebaseFirestore.instance.collection('Users').add(employeeData);
  //     } else {
  //       // Update existing employee
  //       await FirebaseFirestore.instance
  //           .collection('Users')
  //           .where('Codigo', isEqualTo: existingEmployee.codigo)
  //           .get()
  //           .then((querySnapshot) {
  //         if (querySnapshot.docs.isNotEmpty) {
  //           querySnapshot.docs.first.reference.update(employeeData);
  //         }
  //       });
  //     }

  //     // Reload the users list
  //     await _loadUsers();

  //     // Show success message
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(existingEmployee == null
  //             ? 'Empleado creado exitosamente'
  //             : 'Empleado actualizado exitosamente'),
  //         backgroundColor: Colors.green,
  //       ),
  //     );
  //   } catch (e) {
  //     // Show error message
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Error: ${e.toString()}'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }

  Future<void> _saveOrUpdateEmployee(Usuario? existingEmployee,
      List<Usuario> selectedVendedores, String supervisorId) async {
    try {
      final employeeData = {
        'Nombre': _nombresController.text,
        'Apellidos': _apellidosController.text,
        'email': _emailController.text,
        'Telefono': _telefonoController.text,
        'Role': selectedRole,
        'Codigo': _codigoController.text,
        'updatedAt': Timestamp.now(),
      };

      // Obtener el UID del usuario actual
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;

      if (userId == null) {
        // El usuario no está autenticado
        print('Error: Usuario no autenticado');
        return;
      }

      if (existingEmployee == null) {
        // Crear un nuevo empleado
        final nextCode = await _getNextUserCode();
        employeeData['Codigo'] = nextCode;
        employeeData['createdAt'] = Timestamp.now();

        await FirebaseFirestore.instance.collection('Users').add(employeeData);
      } else {
        // Actualizar empleado existente
        await FirebaseFirestore.instance
            .collection('Users')
            .where('Codigo', isEqualTo: existingEmployee.codigo)
            .get()
            .then((querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            querySnapshot.docs.first.reference.update(employeeData);
          }
        });
      }

      // Si el usuario es supervisor y ha seleccionado vendedores, actualizar la subcolección MyTeam del supervisor
      if (selectedRole == 'Supervisor' && selectedVendedores.isNotEmpty) {
        final vendedorIds =
            selectedVendedores.map((vendedor) => vendedor.codigo).toList();

        try {
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(supervisorId)
              .update({
            'MyTeam': FieldValue.arrayUnion(vendedorIds),
          });
        } catch (e) {
          print(
              'Error al actualizar la subcolección MyTeam del supervisor: $e');
        }
      }

      // Reload the users list
      await _loadUsers();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(existingEmployee == null
              ? 'Empleado creado exitosamente'
              : 'Empleado actualizado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: 1  ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // void _showFormDialog(BuildContext context, Usuario? employee) {
  //   final formKey = GlobalKey<FormState>();
  //   final ValueNotifier<bool> isEditable =
  //       ValueNotifier<bool>(employee == null);
  //   final TextEditingController searchController = TextEditingController();
  //   final ValueNotifier<String> searchQuery = ValueNotifier<String>('');
  //   List<Usuario> selectedVendedores = [];

  //   if (employee != null) {
  //     _nombresController.text = employee.nombres;
  //     _apellidosController.text = employee.apellidos;
  //     _emailController.text = employee.email;
  //     _telefonoController.text = employee.telefono;
  //     _codigoController.text = employee.codigo;
  //     _fechaIngresoController.text =
  //         DateFormat('dd/MM/yyyy').format(employee.fechaIngreso);
  //     selectedRole = employee.role;
  //   } else {
  //     _nombresController.clear();
  //     _apellidosController.clear();
  //     _emailController.clear();
  //     _telefonoController.clear();
  //     _fechaIngresoController.clear();
  //     _codigoController.clear();
  //     selectedRole = 'Vendedor';
  //   }

  //   bool isSupervisor = selectedRole == 'Supervisor';

  //   Future<List<Usuario>> fetchVendedores() async {
  //     QuerySnapshot snapshot = await FirebaseFirestore.instance
  //         .collection('Users')
  //         .where('Role', isEqualTo: 'Vendedor')
  //         .get();
  //     return snapshot.docs.map((doc) => Usuario.fromFirestore(doc)).toList();
  //   }

  //   void toggleSelection(Usuario vendedor) {
  //     setState(() {
  //       if (selectedVendedores.contains(vendedor)) {
  //         selectedVendedores.remove(vendedor);
  //       } else {
  //         selectedVendedores.add(vendedor);
  //       }
  //     });
  //   }

  //   // bool matchesSearchQuery(Usuario vendedor, String query) {
  //   //   final fullName = '${vendedor.nombres} ${vendedor.apellidos}';
  //   //   return fullName.toLowerCase().contains(query.toLowerCase());
  //   // }

  //   bool matchesSearchQuery(Usuario vendedor, String query) {
  //     final fullName =
  //         '${vendedor.nombres} ${vendedor.apellidos}'.toLowerCase();
  //     final codigo = vendedor.codigo.toLowerCase();
  //     query = query
  //         .toLowerCase()
  //         .trim(); // Asegurarse de normalizar y limpiar el query

  //     // Retorna true si el query está en el nombre completo o en el código
  //     return fullName.contains(query) || codigo.contains(query);
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
  //             double modalWidth = constraints.maxWidth > 1024
  //                 ? constraints.maxWidth * 0.5
  //                 : constraints.maxWidth > 768
  //                     ? constraints.maxWidth * 0.7
  //                     : constraints.maxWidth * 0.9;

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
  //                         const Text(
  //                           'Nuevo Rol',
  //                           style: TextStyle(
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
  //                                     _nombresController, 'Nombres'),
  //                                 _buildInputField(
  //                                     _apellidosController, 'Apellidos'),
  //                               ]),
  //                               _buildResponsiveRow(isLargeScreen, [
  //                                 _buildInputField(_emailController, 'Email',
  //                                     isEmail: true),
  //                                 _buildInputField(
  //                                     _telefonoController, 'Teléfono'),
  //                               ]),
  //                               _buildResponsiveRow(isLargeScreen, [
  //                                 _buildDropdown(
  //                                   selectedRole,
  //                                   (String? newValue) {
  //                                     setState(() {
  //                                       selectedRole = newValue!;
  //                                     });
  //                                   },
  //                                 ),
  //                                 _buildDatePicker(
  //                                     context,
  //                                     _fechaIngresoController,
  //                                     'Fecha de Ingreso'),
  //                               ]),
  //                             ],
  //                           );
  //                         },
  //                       ),
  //                     ),
  //                     const SizedBox(height: 24),
  //                     if (isSupervisor) ...[
  //                       const Padding(
  //                         padding: EdgeInsets.symmetric(vertical: 8.0),
  //                         child: Text(
  //                           "Lista de Vendedores",
  //                           style: TextStyle(
  //                               fontSize: 18, fontWeight: FontWeight.bold),
  //                         ),
  //                       ),
  //                       TextField(
  //                         controller: searchController,
  //                         onChanged: (value) => searchQuery.value = value,
  //                         decoration: InputDecoration(
  //                           labelText: 'Buscar vendedor',
  //                           prefixIcon: const Icon(Icons.search),
  //                           suffixIcon: IconButton(
  //                             icon: const Icon(Icons.clear),
  //                             onPressed: () {
  //                               searchController.clear();
  //                               searchQuery.value = '';
  //                             },
  //                           ),
  //                           border: OutlineInputBorder(
  //                             borderRadius: BorderRadius.circular(8),
  //                           ),
  //                         ),
  //                       ),
  //                       const SizedBox(height: 12),
  //                       FutureBuilder<List<Usuario>>(
  //                         future: fetchVendedores(),
  //                         builder: (context, snapshot) {
  //                           if (snapshot.connectionState ==
  //                               ConnectionState.waiting) {
  //                             return const Center(
  //                                 child: CircularProgressIndicator());
  //                           } else if (snapshot.hasError) {
  //                             return Text('Error: ${snapshot.error}');
  //                           } else if (!snapshot.hasData ||
  //                               snapshot.data!.isEmpty) {
  //                             return const Text(
  //                                 'No se encontraron vendedores.');
  //                           } else {
  //                             List<Usuario> vendedores = snapshot.data!;
  //                             vendedores.sort(
  //                                 (a, b) => a.nombres.compareTo(b.nombres));

  //                             return ValueListenableBuilder<String>(
  //                               valueListenable: searchQuery,
  //                               builder: (context, query, _) {
  //                                 List<Usuario> filteredVendedores = vendedores
  //                                     .where((vendedor) =>
  //                                         matchesSearchQuery(vendedor, query))
  //                                     .toList();

  //                                 return SizedBox(
  //                                   height: 200,
  //                                   child: filteredVendedores.isEmpty
  //                                       ? const Center(
  //                                           child: Text(
  //                                               'No se encontraron vendedores'))
  //                                       : ListView.builder(
  //                                           shrinkWrap: true,
  //                                           itemCount:
  //                                               filteredVendedores.length,
  //                                           itemBuilder: (context, index) {
  //                                             final vendedor =
  //                                                 filteredVendedores[index];
  //                                             bool isSelected =
  //                                                 selectedVendedores
  //                                                     .contains(vendedor);
  //                                             return Container(
  //                                               margin:
  //                                                   const EdgeInsets.symmetric(
  //                                                       vertical: 4),
  //                                               decoration: BoxDecoration(
  //                                                 color: Colors.grey[100],
  //                                                 borderRadius:
  //                                                     BorderRadius.circular(8),
  //                                                 border: Border.all(
  //                                                     color:
  //                                                         Colors.grey.shade300),
  //                                               ),
  //                                               child: ListTile(
  //                                                 leading: const Icon(
  //                                                     Icons.person,
  //                                                     color: Colors.indigo),
  //                                                 title: Text(
  //                                                   '${vendedor.nombres} ${vendedor.apellidos}',
  //                                                   style: const TextStyle(
  //                                                     fontWeight:
  //                                                         FontWeight.w600,
  //                                                   ),
  //                                                 ),
  //                                                 trailing: Row(
  //                                                   mainAxisSize:
  //                                                       MainAxisSize.min,
  //                                                   children: [
  //                                                     Text(
  //                                                       vendedor.codigo,
  //                                                       style: TextStyle(
  //                                                         color: Colors
  //                                                             .indigo.shade700,
  //                                                         fontWeight:
  //                                                             FontWeight.bold,
  //                                                       ),
  //                                                     ),
  //                                                     Checkbox(
  //                                                       value: isSelected,
  //                                                       onChanged:
  //                                                           (bool? value) {
  //                                                         toggleSelection(
  //                                                             vendedor);
  //                                                       },
  //                                                     ),
  //                                                   ],
  //                                                 ),
  //                                               ),
  //                                             );
  //                                           },
  //                                         ),
  //                                 );
  //                               },
  //                             );
  //                           }
  //                         },
  //                       ),
  //                     ],
  //                     const SizedBox(height: 24),
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.end,
  //                       children: [
  //                         Flexible(
  //                           child: TextButton.icon(
  //                             onPressed: () => Navigator.of(context).pop(),
  //                             icon: const Icon(Icons.cancel),
  //                             label: const Text('Cancelar'),
  //                           ),
  //                         ),
  //                         const SizedBox(width: 8),
  //                         Flexible(
  //                           child: ElevatedButton.icon(
  //                             onPressed: () {
  //                               if (formKey.currentState!.validate()) {
  //                                 _saveOrUpdateEmployee(employee);
  //                                 Navigator.of(context).pop();
  //                               }
  //                             },
  //                             icon: const Icon(Icons.save),
  //                             label: const Text('Guardar'),
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

//   void _showFormDialog(BuildContext context, Usuario? employee) {
//   final formKey = GlobalKey<FormState>();
//   final ValueNotifier<bool> isEditable =
//       ValueNotifier<bool>(employee == null);
//   final TextEditingController searchController = TextEditingController();
//   final ValueNotifier<String> searchQuery = ValueNotifier<String>('');
//   List<Usuario> selectedVendedores = [];

//   if (employee != null) {
//     _nombresController.text = employee.nombres;
//     _apellidosController.text = employee.apellidos;
//     _emailController.text = employee.email;
//     _telefonoController.text = employee.telefono;
//     _codigoController.text = employee.codigo;
//     _fechaIngresoController.text =
//         DateFormat('dd/MM/yyyy').format(employee.fechaIngreso);
//     selectedRole = employee.role;
//   } else {
//     _nombresController.clear();
//     _apellidosController.clear();
//     _emailController.clear();
//     _telefonoController.clear();
//     _fechaIngresoController.clear();
//     _codigoController.clear();
//     selectedRole = 'Vendedor';
//   }

//   bool isSupervisor = selectedRole == 'Supervisor';

//   Future<List<Usuario>> fetchVendedores() async {
//     QuerySnapshot snapshot = await FirebaseFirestore.instance
//         .collection('Users')
//         .where('Role', isEqualTo: 'Vendedor')
//         .get();
//     return snapshot.docs.map((doc) => Usuario.fromFirestore(doc)).toList();
//   }

//   void toggleSelection(Usuario vendedor) {
//     setState(() {
//       if (selectedVendedores.contains(vendedor)) {
//         selectedVendedores.remove(vendedor);
//       } else {
//         selectedVendedores.add(vendedor);
//       }
//     });
//   }

//   bool matchesSearchQuery(Usuario vendedor, String query) {
//     final fullName =
//         '${vendedor.nombres} ${vendedor.apellidos}'.toLowerCase();
//     final codigo = vendedor.codigo.toLowerCase();
//     query = query
//         .toLowerCase()
//         .trim(); // Asegurarse de normalizar y limpiar el query

//     // Retorna true si el query está en el nombre completo o en el código
//     return fullName.contains(query) || codigo.contains(query);
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
//             double modalWidth = constraints.maxWidth > 1024
//                 ? constraints.maxWidth * 0.5
//                 : constraints.maxWidth > 768
//                     ? constraints.maxWidth * 0.7
//                     : constraints.maxWidth * 0.9;

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
//                         const Text(
//                           'Nuevo Rol',
//                           style: TextStyle(
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
//                                     _nombresController, 'Nombres'),
//                                 _buildInputField(
//                                     _apellidosController, 'Apellidos'),
//                               ]),
//                               _buildResponsiveRow(isLargeScreen, [
//                                 _buildInputField(_emailController, 'Email',
//                                     isEmail: true),
//                                 _buildInputField(
//                                     _telefonoController, 'Teléfono'),
//                               ]),
//                               _buildResponsiveRow(isLargeScreen, [
//                                 _buildDropdown(
//                                   selectedRole,
//                                   (String? newValue) {
//                                     setState(() {
//                                       selectedRole = newValue!;
//                                     });
//                                   },
//                                 ),
//                                 _buildDatePicker(
//                                     context,
//                                     _fechaIngresoController,
//                                     'Fecha de Ingreso'),
//                               ]),
//                             ],
//                           );
//                         },
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     if (isSupervisor) ...[
//                       const Padding(
//                         padding: EdgeInsets.symmetric(vertical: 8.0),
//                         child: Text(
//                           "Lista de Vendedores",
//                           style: TextStyle(
//                               fontSize: 18, fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                       TextField(
//                         controller: searchController,
//                         onChanged: (value) => searchQuery.value = value,
//                         decoration: InputDecoration(
//                           labelText: 'Buscar vendedor',
//                           prefixIcon: const Icon(Icons.search),
//                           suffixIcon: IconButton(
//                             icon: const Icon(Icons.clear),
//                             onPressed: () {
//                               searchController.clear();
//                               searchQuery.value = '';
//                             },
//                           ),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       FutureBuilder<List<Usuario>>(
//                         future: fetchVendedores(),
//                         builder: (context, snapshot) {
//                           if (snapshot.connectionState ==
//                               ConnectionState.waiting) {
//                             return const Center(
//                                 child: CircularProgressIndicator());
//                           } else if (snapshot.hasError) {
//                             return Text('Error: ${snapshot.error}');
//                           } else if (!snapshot.hasData ||
//                               snapshot.data!.isEmpty) {
//                             return const Text(
//                                 'No se encontraron vendedores.');
//                           } else {
//                             List<Usuario> vendedores = snapshot.data!;
//                             vendedores.sort(
//                                 (a, b) => a.nombres.compareTo(b.nombres));

//                             return ValueListenableBuilder<String>(
//                               valueListenable: searchQuery,
//                               builder: (context, query, _) {
//                                 List<Usuario> filteredVendedores = vendedores
//                                     .where((vendedor) =>
//                                         matchesSearchQuery(vendedor, query))
//                                     .toList();

//                                 return SizedBox(
//                                   height: 200,
//                                   child: filteredVendedores.isEmpty
//                                       ? const Center(
//                                           child: Text(
//                                               'No se encontraron vendedores'))
//                                       : ListView.builder(
//                                           shrinkWrap: true,
//                                           itemCount:
//                                               filteredVendedores.length,
//                                           itemBuilder: (context, index) {
//                                             final vendedor =
//                                                 filteredVendedores[index];
//                                             bool isSelected =
//                                                 selectedVendedores
//                                                     .contains(vendedor);
//                                             return Container(
//                                               margin:
//                                                   const EdgeInsets.symmetric(
//                                                       vertical: 4),
//                                               decoration: BoxDecoration(
//                                                 color: Colors.grey[100],
//                                                 borderRadius:
//                                                     BorderRadius.circular(8),
//                                                 border: Border.all(
//                                                     color:
//                                                         Colors.grey.shade300),
//                                               ),
//                                               child: ListTile(
//                                                 leading: const Icon(
//                                                     Icons.person,
//                                                     color: Colors.indigo),
//                                                 title: Text(
//                                                   '${vendedor.nombres} ${vendedor.apellidos}',
//                                                   style: const TextStyle(
//                                                     fontWeight:
//                                                         FontWeight.w600,
//                                                   ),
//                                                 ),
//                                                 trailing: Row(
//                                                   mainAxisSize:
//                                                       MainAxisSize.min,
//                                                   children: [
//                                                     Text(
//                                                       vendedor.codigo,
//                                                       style: TextStyle(
//                                                         color: Colors
//                                                             .indigo.shade700,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                       ),
//                                                     ),
//                                                     Checkbox(
//                                                       value: isSelected,
//                                                       onChanged:
//                                                           (bool? value) {
//                                                         toggleSelection(
//                                                             vendedor);
//                                                       },
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             );
//                                           },
//                                         ),
//                                 );
//                               },
//                             );
//                           }
//                         },
//                       ),
//                     ],
//                     const SizedBox(height: 24),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         Flexible(
//                           child: TextButton.icon(
//                             onPressed: () => Navigator.of(context).pop(),
//                             icon: const Icon(Icons.cancel),
//                             label: const Text('Cancelar'),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Flexible(
//                           child: ElevatedButton.icon(
//                             onPressed: () {
//                               if (formKey.currentState!.validate()) {
//                                 _saveOrUpdateEmployee(employee);
//                                 Navigator.of(context).pop();
//                               }
//                             },
//                             icon: const Icon(Icons.save),
//                             label: const Text('Guardar'),
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

  void _showFormDialog(BuildContext context, Usuario? employee) {
    final formKey = GlobalKey<FormState>();
    final ValueNotifier<bool> isEditable =
        ValueNotifier<bool>(employee == null);
    final TextEditingController searchController = TextEditingController();
    final ValueNotifier<String> searchQuery = ValueNotifier<String>('');
    final ValueNotifier<List<Usuario>> selectedVendedoresNotifier =
        ValueNotifier<List<Usuario>>([]);

    if (employee != null) {
      _nombresController.text = employee.nombres;
      _apellidosController.text = employee.apellidos;
      _emailController.text = employee.email;
      _telefonoController.text = employee.telefono;
      _codigoController.text = employee.codigo;
      _fechaIngresoController.text =
          DateFormat('dd/MM/yyyy').format(employee.fechaIngreso);
      selectedRole = employee.role;
    } else {
      _nombresController.clear();
      _apellidosController.clear();
      _emailController.clear();
      _telefonoController.clear();
      _fechaIngresoController.clear();
      _codigoController.clear();
      selectedRole = 'Vendedor';
    }

    bool isSupervisor = selectedRole == 'Supervisor';

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
                      if (isSupervisor) ...[
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
                                                              FontWeight.w600,
                                                        ),
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
                                  // Aquí podrías usar selectedVendedoresNotifier.value
                                  // para obtener los vendedores seleccionados
                                  //_saveOrUpdateEmployee(employee);
                                  _saveOrUpdateEmployee(employee,
                                      selectedVendedoresNotifier.value, employee.codigo.toString());
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
