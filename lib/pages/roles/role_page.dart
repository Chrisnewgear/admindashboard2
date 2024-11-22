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

  Future<void> _saveOrUpdateEmployee(Usuario? existingEmployee) async {
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

      if (existingEmployee == null) {
        // Create a new employee
        final nextCode = await _getNextUserCode();
        employeeData['Codigo'] = nextCode;
        employeeData['createdAt'] = Timestamp.now();

        await FirebaseFirestore.instance.collection('Users').add(employeeData);
      } else {
        // Update existing employee
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
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showFormDialog(BuildContext context, Usuario? employee) {
    final formKey = GlobalKey<FormState>();
    final ValueNotifier<bool> isEditable =
        ValueNotifier<bool>(employee == null);
    //String? selectedField;
    String searchQuery = '';

    // Verificar rol del usuario logueado (supongamos que está almacenado en loggedInUserRole)

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

    // Función para obtener la lista de usuarios Vendedores desde Firebase
    Future<List<Usuario>> fetchVendedores() async {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('Role', isEqualTo: 'Vendedor')
          .get();

      return snapshot.docs.map((doc) => Usuario.fromFirestore(doc)).toList();
    }

    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return Dialog(
    //       shape: RoundedRectangleBorder(
    //         borderRadius: BorderRadius.circular(16),
    //       ),
    //       elevation: 0,
    //       backgroundColor: Colors.transparent,
    //       child: LayoutBuilder(
    //         builder: (context, constraints) {
    //           // Ajustamos los breakpoints para mejor soporte de tablets
    //           double modalWidth;
    //           if (constraints.maxWidth > 1024) {
    //             // iPad Pro y pantallas grandes
    //             modalWidth =
    //                 constraints.maxWidth * 0.5; // 50% del ancho disponible
    //           } else if (constraints.maxWidth > 768) {
    //             // iPads regulares
    //             modalWidth = constraints.maxWidth * 0.7;
    //           } else {
    //             modalWidth = constraints.maxWidth * 0.9;
    //           }

    //           return Container(
    //             width: modalWidth,
    //             padding: const EdgeInsets.all(24),
    //             decoration: BoxDecoration(
    //               color: Colors.white,
    //               borderRadius: BorderRadius.circular(16),
    //             ),
    //             child: SingleChildScrollView(
    //               child: Column(
    //                 mainAxisSize: MainAxisSize.min,
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: <Widget>[
    //                   Row(
    //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                     children: [
    //                       Text(
    //                         employee == null ? 'Nuevo Rol' : 'Editar Rol',
    //                         style: const TextStyle(
    //                           fontSize: 24,
    //                           fontWeight: FontWeight.bold,
    //                           color: Colors.black87,
    //                         ),
    //                       ),
    //                       IconButton(
    //                         icon:
    //                             const Icon(Icons.close, color: Colors.black54),
    //                         onPressed: () => Navigator.of(context).pop(),
    //                       ),
    //                     ],
    //                   ),
    //                   const SizedBox(height: 24),
    //                   Form(
    //                     key: formKey,
    //                     child: ValueListenableBuilder<bool>(
    //                       valueListenable: isEditable,
    //                       builder: (context, editable, _) {
    //                         bool isLargeScreen = constraints.maxWidth > 986;
    //                         return Column(
    //                           children: [
    //                             _buildResponsiveRow(isLargeScreen, [
    //                               _buildInputField(
    //                                   _nombresController, 'Nombres'),
    //                               _buildInputField(
    //                                   _apellidosController, 'Apellidos'),
    //                             ]),
    //                             _buildResponsiveRow(isLargeScreen, [
    //                               _buildInputField(_emailController, 'Email',
    //                                   isEmail: true),
    //                               _buildInputField(
    //                                   _telefonoController, 'Teléfono'),
    //                             ]),
    //                             _buildResponsiveRow(isLargeScreen, [
    //                               _buildDropdown(
    //                                 selectedRole,
    //                                 (String? newValue) {
    //                                   setState(() {
    //                                     selectedRole = newValue!;
    //                                   });
    //                                 },
    //                               ),
    //                               _buildDatePicker(
    //                                   context,
    //                                   _fechaIngresoController,
    //                                   'Fecha de Ingreso'),
    //                             ]),

    //                             // Mostrar DropdownButton si el usuario es Supervisor
    //                             if (isSupervisor)
    //                               Padding(
    //                                 padding: const EdgeInsets.all(8.0),
    //                                 child: Column(
    //                                   crossAxisAlignment:
    //                                       CrossAxisAlignment.start,
    //                                   children: [
    //                                     Text("Selecciona un campo:"),
    //                                     DropdownButton<String>(
    //                                       value: selectedField,
    //                                       items: [
    //                                         DropdownMenuItem(
    //                                           value: 'Codigo',
    //                                           child: Text('Codigo'),
    //                                         ),
    //                                         DropdownMenuItem(
    //                                           value: 'Nombre',
    //                                           child: Text('Nombre'),
    //                                         ),
    //                                         DropdownMenuItem(
    //                                           value: 'Apellidos',
    //                                           child: Text('Apellidos'),
    //                                         ),
    //                                       ],
    //                                       onChanged: (String? newValue) {
    //                                         selectedField = newValue!;
    //                                         // Implementar acciones según el campo seleccionado
    //                                       },
    //                                     ),
    //                                   ],
    //                                 ),
    //                               ),
    //                           ],
    //                         );
    //                       },
    //                     ),
    //                   ),
    //                   const SizedBox(height: 24),
    //                   Row(
    //                     mainAxisAlignment: MainAxisAlignment.end,
    //                     children: [
    //                       if (employee != null) const SizedBox(width: 8),
    //                       Flexible(
    //                         child: ConstrainedBox(
    //                           constraints: BoxConstraints(
    //                             maxWidth:
    //                                 MediaQuery.of(context).size.width < 768
    //                                     ? double.infinity
    //                                     : 200,
    //                           ),
    //                           child: TextButton.icon(
    //                             onPressed: () => Navigator.of(context).pop(),
    //                             icon: const Icon(Icons.cancel),
    //                             label: MediaQuery.of(context).size.width < 768
    //                                 ? const SizedBox.shrink()
    //                                 : const Text('Cancelar'),
    //                             style: TextButton.styleFrom(
    //                               padding: EdgeInsets.symmetric(
    //                                 horizontal:
    //                                     MediaQuery.of(context).size.width < 768
    //                                         ? 12
    //                                         : 16,
    //                                 vertical: 12,
    //                               ),
    //                             ),
    //                           ),
    //                         ),
    //                       ),
    //                       const SizedBox(width: 8),
    //                       Flexible(
    //                         child: ConstrainedBox(
    //                           constraints: BoxConstraints(
    //                             maxWidth:
    //                                 MediaQuery.of(context).size.width < 768
    //                                     ? double.infinity
    //                                     : 200,
    //                           ),
    //                           child: ElevatedButton.icon(
    //                             style: ElevatedButton.styleFrom(
    //                               backgroundColor: Colors.indigo,
    //                               shape: RoundedRectangleBorder(
    //                                 borderRadius: BorderRadius.circular(8),
    //                               ),
    //                               padding: EdgeInsets.symmetric(
    //                                 horizontal:
    //                                     MediaQuery.of(context).size.width < 768
    //                                         ? 12
    //                                         : 16,
    //                                 vertical: 12,
    //                               ),
    //                             ),
    //                             onPressed: () {
    //                               if (formKey.currentState!.validate()) {
    //                                 _saveOrUpdateEmployee(employee);
    //                                 Navigator.of(context).pop();
    //                               }
    //                             },
    //                             icon: const Icon(
    //                               Icons.save,
    //                               color: Colors.white,
    //                             ),
    //                             label: MediaQuery.of(context).size.width < 768
    //                                 ? const SizedBox.shrink()
    //                                 : const Text(
    //                                     'Guardar',
    //                                     style: TextStyle(color: Colors.white),
    //                                   ),
    //                           ),
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                 ],
    //               ),
    //             ),
    //           );
    //         },
    //       ),
    //     );
    //   },
    // );

    // Declaración de la lista para almacenar los vendedores seleccionados
    List<Usuario> selectedVendedores = [];

// Método para seleccionar o deseleccionar vendedores
    void toggleSelection(Usuario vendedor) {
      setState(() {
        if (selectedVendedores.contains(vendedor)) {
          selectedVendedores.remove(vendedor);
        } else {
          selectedVendedores.add(vendedor);
        }
      });
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
                              _buildInputField(_nombresController, 'Nombres'),
                              _buildInputField(_apellidosController, 'Apellidos'),
                            ]),
                            _buildResponsiveRow(isLargeScreen, [
                              _buildInputField(_emailController, 'Email', isEmail: true),
                              _buildInputField(_telefonoController, 'Teléfono'),
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

                  // Mostrar lista de Vendedores solo si isSupervisor es true
                  if (isSupervisor) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "Lista de Vendedores",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value.toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Buscar vendedor',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<List<Usuario>>(
                      future: fetchVendedores(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text('No se encontraron vendedores.');
                        } else {
                          // Ordenar los vendedores por nombre
                          List<Usuario> vendedores = snapshot.data!;
                          vendedores.sort((a, b) => a.nombres.compareTo(b.nombres));
                          
                          // Filtrar los vendedores según la búsqueda
                          List<Usuario> filteredVendedores = vendedores.where((vendedor) {
                            String nombreCompleto = '${vendedor.nombres} ${vendedor.apellidos}'.toLowerCase();
                            return nombreCompleto.contains(searchQuery) ||
                                   vendedor.codigo.toLowerCase().contains(searchQuery);
                          }).toList();

                          return SizedBox(
                            height: 200, // Altura fija para mostrar solo 3 ListTile
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: filteredVendedores.length,
                              itemBuilder: (context, index) {
                                final vendedor = filteredVendedores[index];
                                bool isSelected = selectedVendedores.contains(vendedor);
                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: ListTile(
                                    leading: const Icon(Icons.person, color: Colors.indigo),
                                    title: Text(
                                      '${vendedor.nombres} ${vendedor.apellidos}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          vendedor.codigo,
                                          style: TextStyle(
                                            color: Colors.indigo.shade700,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Checkbox(
                                          value: isSelected,
                                          onChanged: (bool? value) {
                                            toggleSelection(vendedor);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
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
                              _saveOrUpdateEmployee(employee);
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
