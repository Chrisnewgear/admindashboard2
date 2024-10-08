// ignore_for_file: duplicate_import

import 'dart:math';

import 'package:admindashboard/models/employee.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:admindashboard/models/employee.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';

class RoleManagementWidget extends StatefulWidget {
  const RoleManagementWidget({super.key});

  @override
  _RoleManagementWidgetState createState() => _RoleManagementWidgetState();
}

class _RoleManagementWidgetState extends State<RoleManagementWidget> {
  //final _formKey = GlobalKey<FormState>();
  String selectedRole = 'Vendedor';
  List<String> roles = ['Vendedor', 'Supervisor'];
  List<Employee> employees = [];

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
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('Users').get();
      setState(() {
        employees = querySnapshot.docs
            .map((doc) => Employee.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
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

  Future<void> _saveOrUpdateEmployee(Employee? existingEmployee) async {
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

  void _showFormDialog(BuildContext context, Employee? employee) {
    final _formKey = GlobalKey<FormState>();

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

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Ajustar el ancho del modal dependiendo del tamaño de la pantalla
              double modalWidth = constraints.maxWidth > 600
                  ? constraints.maxWidth * 0.4 // Pantallas grandes
                  : constraints.maxWidth * 0.9; // Pantallas pequeñas

              return Container(
                width: modalWidth, // Se ajusta el ancho del modal
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      employee == null ? 'Nuevo Empleado' : 'Editar Empleado',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Si el ancho es mayor a 600px, usar 2 columnas
                          bool isLargeScreen = constraints.maxWidth > 600;

                          return Column(
                            children: [
                              // Campos de nombres y apellidos
                              isLargeScreen
                                  ? Row(
                                      children: [
                                        Expanded(
                                          child: _buildTextField(
                                              _nombresController, 'Nombres'),
                                        ),
                                        const SizedBox(width: 20),
                                        Expanded(
                                          child: _buildTextField(
                                              _apellidosController,
                                              'Apellidos'),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        _buildTextField(
                                            _nombresController, 'Nombres'),
                                        const SizedBox(height: 15),
                                        _buildTextField(
                                            _apellidosController, 'Apellidos'),
                                      ],
                                    ),
                              const SizedBox(height: 15),
                              // Campos de email y teléfono
                              isLargeScreen
                                  ? Row(
                                      children: [
                                        Expanded(
                                          child: _buildTextField(
                                              _emailController, 'Email',
                                              isEmail: true),
                                        ),
                                        const SizedBox(width: 20),
                                        Expanded(
                                          child: _buildTextField(
                                              _telefonoController, 'Teléfono'),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        _buildTextField(
                                            _emailController, 'Email',
                                            isEmail: true),
                                        const SizedBox(height: 15),
                                        _buildTextField(
                                            _telefonoController, 'Teléfono'),
                                      ],
                                    ),
                              const SizedBox(height: 15),
                              // Campos de Rol y Fecha de Ingreso
                              isLargeScreen
                                  ? Row(
                                      children: [
                                        Expanded(
                                          child: _buildDropdown(selectedRole,
                                              (String? newValue) {
                                            selectedRole = newValue!;
                                          }),
                                        ),
                                        const SizedBox(width: 20),
                                        Expanded(
                                          child: _buildDatePicker(
                                              context, _fechaIngresoController),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        _buildDropdown(selectedRole,
                                            (String? newValue) {
                                          selectedRole = newValue!;
                                        }),
                                        const SizedBox(height: 15),
                                        _buildDatePicker(
                                            context, _fechaIngresoController),
                                      ],
                                    ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          child: Text('Cancelar',
                              style: TextStyle(color: Colors.grey[600])),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _saveOrUpdateEmployee(employee);
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.save, color: Colors.white),
                              SizedBox(width: 5),
                              Text(
                                'Guardar',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
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
  Widget _buildTextField(TextEditingController controller, String label,
      {bool isEmail = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo es requerido';
        }
        if (isEmail &&
            !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Ingrese un email válido';
        }
        return null;
      },
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
      appBar: AppBar(
        title: const Text('Administrar Roles'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Administrar Roles',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildUserTable(),
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
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lista de Empleados',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                // ElevatedButton(
                //   onPressed: () => _showFormDialog(context, null),
                //   child: const Text('Nuevo Empleado'),
                // ),
              ],
            ),
            const SizedBox(height: 16),
            employees.isEmpty
                ? const SizedBox(
                    height: 400,
                    child: Center(
                      child:
                          CircularProgressIndicator(), // Use a circular indicator
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
                            child: Text('Role',
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
                      rows: employees
                        .map((employee) => DataRow2(
                                cells: [
                                  DataCell(
                                      Center(child: Text(employee.codigo))),
                                  DataCell(
                                      Center(child: Text(employee.nombres))),
                                  DataCell(
                                      Center(child: Text(employee.apellidos))),
                                  DataCell(Center(child: Text(employee.email))),
                                  DataCell(
                                      Center(child: Text(employee.telefono))),
                                  DataCell(
                                    Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getRoleColor(employee.role),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          employee.role,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // ... (otras celdas) ...
                                  DataCell(
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(DateFormat('dd/MM/yyyy')
                                            .format(employee.fechaIngreso)),
                                        PopupMenuButton<String>(
                                          onSelected: (value) {
                                            if (value == 'Eliminar') {
                                              _deleteEmployee(employee);
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
                                    _showFormDialog(context, employee),
                              ))
                          .toList(),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _deleteEmployee(Employee employee) async {
    // Mostrar un diálogo de confirmación
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text(
              '¿Está seguro de que desea eliminar a ${employee.nombres} ${employee.apellidos}?'),
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
            .collection('Users')
            .where('email', isEqualTo: employee.email)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Eliminar el documento
          await querySnapshot.docs.first.reference.delete();

          // Actualizar la lista de empleados
          setState(() {
            employees.removeWhere((e) => e.email == employee.email);
          });

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

  Widget _buildDatePicker(
      BuildContext context, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Fecha Ingreso',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey[100],
        suffixIcon: const Icon(Icons.calendar_today),
      ),
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
      readOnly: true,
    );
  }
}
