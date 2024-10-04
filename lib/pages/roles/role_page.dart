// ignore_for_file: duplicate_import

import 'package:admindashboard/models/employee.dart';
//import 'package:admindashboard/widgets/content_box.dart';
import 'package:flutter/material.dart';
//import 'package:admindashboard/constants/style.dart';
import 'package:admindashboard/models/employee.dart';
import 'package:flutter/material.dart';
//import 'package:admindashboard/constants/style.dart';
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

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('Users').get();
    setState(() {
      employees = querySnapshot.docs
          .map((doc) => Employee(
                nombres: doc['Nombre'] ?? '',
                apellidos: doc['Apellidos'] ?? '',
                email: doc['email'] ?? '',
                telefono: doc['Telefono'] ?? '',
                role: doc['Role'] ?? 'Vendedor',
                codigo: doc['Codigo'] ?? '',
                fechaIngreso: doc['createdAt'] != null
                    ? (doc['createdAt'] as Timestamp).toDate()
                    : DateTime.now(),
              ))
          .toList();
    });
  }

  void _showFormDialog(BuildContext context, Employee? employee) {
    final _formKey = GlobalKey<FormState>();
    String selectedRole = employee?.role ?? 'Vendedor';
    final TextEditingController _nombresController =
        TextEditingController(text: employee?.nombres ?? '');
    final TextEditingController _apellidosController =
        TextEditingController(text: employee?.apellidos ?? '');
    final TextEditingController _emailController =
        TextEditingController(text: employee?.email ?? '');
    final TextEditingController _telefonoController =
        TextEditingController(text: employee?.telefono ?? '');
    final TextEditingController _fechaIngresoController = TextEditingController(
      text: employee != null
          ? DateFormat('dd/MM/yyyy').format(employee.fechaIngreso)
          : '',
    );

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
                              // Aquí iría la lógica para guardar o actualizar el empleado
                              Navigator.of(context).pop();
                              // Después de guardar, actualiza la lista de empleados
                              _loadUsers();
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

  // Widget _buildForm() {
  //   return Card(
  //     elevation: 4,
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     child: Padding(
  //       padding: const EdgeInsets.all(24),
  //       child: Form(
  //         key: _formKey,
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               'Formulario de Empleado',
  //               style: TextStyle(
  //                   fontSize: 24, fontWeight: FontWeight.bold, color: dark),
  //             ),
  //             const SizedBox(height: 24),
  //             _buildFormSection([
  //               _buildResponsiveRow([
  //                 _buildCustomTextField(
  //                     controller: _nombresController,
  //                     label: 'Nombres',
  //                     required: true),
  //                 _buildCustomTextField(
  //                     controller: _apellidosController,
  //                     label: 'Apellidos',
  //                     required: true),
  //               ]),
  //               const SizedBox(height: 16),
  //               _buildResponsiveRow([
  //                 _buildCustomTextField(
  //                     controller: _emailController,
  //                     label: 'Email',
  //                     hintText: 'email@dominio.com',
  //                     required: true),
  //                 _buildCustomTextField(
  //                     controller: _telefonoController,
  //                     label: 'Teléfono',
  //                     hintText: '09-1234-5678'),
  //               ]),
  //               const SizedBox(height: 16),
  //               _buildResponsiveRow([
  //                 //_buildDropdown(),
  //                 _buildDatePicker(context, _fechaIngresoController),
  //               ]),
  //               const SizedBox(height: 32),
  //               // Center(
  //               //   child: ElevatedButton(
  //               //     onPressed: _submitForm,
  //               //     style: ElevatedButton.styleFrom(
  //               //       primary: Colors.blue[700],
  //               //       padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
  //               //       shape: RoundedRectangleBorder(
  //               //         borderRadius: BorderRadius.circular(8),
  //               //       ),
  //               //     ),
  //               //     child: Text('Guardar', style: TextStyle(color: Colors.white, fontSize: 16)),
  //               //   ),
  //               // ),
  //             ]),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // void _showFormModal(BuildContext context, Employee? employee) {
  //   if (employee != null) {
  //     _nombresController.text = employee.nombres;
  //     _apellidosController.text = employee.apellidos;
  //     _emailController.text = employee.email;
  //     _telefonoController.text = employee.telefono;
  //     _fechaIngresoController.text =
  //         DateFormat('dd/MM/yyyy').format(employee.fechaIngreso);
  //     selectedRole = employee.role;
  //   } else {
  //     _clearForm();
  //   }

  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text(employee == null ? 'Nuevo Empleado' : 'Editar Empleado'),
  //         content: SingleChildScrollView(
  //           child: _buildForm(),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('Cancelar'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           TextButton(
  //             child: const Text('Guardar'),
  //             onPressed: () {
  //               if (_formKey.currentState!.validate()) {
  //                 // Aquí iría la lógica para guardar o actualizar el empleado
  //                 Navigator.of(context).pop();
  //               }
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

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
                  'Lista de Empleados',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () => _showFormDialog(context, null),
                  child: const Text('Nuevo Empleado'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 400,
              child: DataTable2(
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: 600,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
                columns: const [
                  DataColumn2(label: Text('Codigo'), size: ColumnSize.L),
                  DataColumn2(label: Text('Nombres'), size: ColumnSize.L),
                  DataColumn2(label: Text('Apellidos'), size: ColumnSize.L),
                  DataColumn2(label: Text('Email'), size: ColumnSize.L),
                  DataColumn2(label: Text('Teléfono'), size: ColumnSize.M),
                  DataColumn2(label: Text('Role'), size: ColumnSize.S),
                  DataColumn2(label: Text('Fecha Ingreso'), size: ColumnSize.M),
                ],
                rows: employees
                    .map((employee) => DataRow2(
                          cells: [
                            DataCell(Text(employee.codigo)),
                            DataCell(Text(employee.nombres)),
                            DataCell(Text(employee.apellidos)),
                            DataCell(Text(employee.email)),
                            DataCell(Text(employee.telefono)),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getRoleColor(employee.role),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  employee.role,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            DataCell(Text(DateFormat('dd/MM/yyyy')
                                .format(employee.fechaIngreso))),
                          ],
                          color: WidgetStateProperty.resolveWith<Color?>(
                            (Set<WidgetState> states) {
                              if (states.contains(WidgetState.hovered)) {
                                return Colors.grey[300];
                              }
                              return null;
                            },
                          ),
                          onDoubleTap: () => _showFormDialog(context, employee),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red[400]!;
      case 'supervisor':
        return Colors.green[400]!;
      case 'vendedor':
        return Colors.blue[400]!;
      default:
        return Colors.grey[400]!;
    }
  }

  // void _submitForm() {
  //   if (_formKey.currentState!.validate()) {
  //     final newEmployee = Employee(
  //       nombres: _nombresController.text,
  //       apellidos: _apellidosController.text,
  //       email: _emailController.text,
  //       telefono: _telefonoController.text,
  //       role: selectedRole,
  //       fechaIngreso: _fechaIngresoController,
  //     );

  //     setState(() {
  //       employees.add(newEmployee);
  //     });

  //     _clearForm();
  //   }
  // }

  void _clearForm() {
    _nombresController.clear();
    _apellidosController.clear();
    _emailController.clear();
    _telefonoController.clear();
    _fechaIngresoController.clear();
    setState(() {
      selectedRole = 'Vendedor';
    });
  }

  // Widget _buildAccordions() {
  //   return ExpansionPanelList(
  //     expansionCallback: (int index, bool isExpanded) {
  //       setState(() {
  //         roles[index] = roles[index] == 'Vendedor' ? 'Supervisor' : 'Vendedor';
  //       });
  //     },
  //     children: roles.map<ExpansionPanel>((String role) {
  //       return ExpansionPanel(
  //         headerBuilder: (BuildContext context, bool isExpanded) {
  //           return ListTile(
  //             title: Text(role, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  //           );
  //         },
  //         body: _buildEmployeeList(role),
  //         isExpanded: true,
  //       );
  //     }).toList(),
  //   );
  // }

  // Widget _buildEmployeeList(String role) {
  //   final roleEmployees =
  //       employees.where((employee) => employee.role == role).toList();
  //   return ListView.builder(
  //     shrinkWrap: true,
  //     physics: const NeverScrollableScrollPhysics(),
  //     itemCount: roleEmployees.length,
  //     itemBuilder: (context, index) {
  //       final employee = roleEmployees[index];
  //       return ListTile(
  //         title: Text('${employee.nombres} ${employee.apellidos}'),
  //         subtitle: Text(employee.email),
  //         trailing: Text(employee.fechaIngreso.toString()),
  //       );
  //     },
  //   );
  // }

  // Widget _buildFormSection(List<Widget> children) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.stretch,
  //     children: children,
  //   );
  // }

  // Widget _buildResponsiveRow(List<Widget> children) {
  //   return Row(
  //     children: children.map((child) => Expanded(child: child)).toList(),
  //   );
  // }

  // Widget _buildCustomTextField({
  //   required TextEditingController controller,
  //   required String label,
  //   String? hintText,
  //   bool required = false,
  // }) {
  //   return Expanded(
  //     child: Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: 8),
  //       child: TextFormField(
  //         controller: controller,
  //         decoration: InputDecoration(
  //           labelText: label,
  //           hintText: hintText,
  //           border: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(8),
  //           ),
  //           filled: true,
  //           fillColor: Colors.grey[100],
  //         ),
  //         validator: required
  //             ? (value) {
  //                 if (value == null || value.isEmpty) {
  //                   return 'Este campo es requerido';
  //                 }
  //                 return null;
  //               }
  //             : null,
  //       ),
  //     ),
  //   );
  // }

  Widget _buildDropdown(String selectedRole, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedRole,
      items: ['Vendedor', 'Supervisor', 'Admin'].map((String value) {
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
