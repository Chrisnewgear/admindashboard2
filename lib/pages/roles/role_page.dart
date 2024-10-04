// ignore_for_file: duplicate_import

import 'package:admindashboard/models/employee.dart';
import 'package:flutter/material.dart';
import 'package:admindashboard/constants/style.dart';
import 'package:admindashboard/models/employee.dart';
import 'package:flutter/material.dart';
import 'package:admindashboard/constants/style.dart';
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
  final _formKey = GlobalKey<FormState>();
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
    final querySnapshot = await FirebaseFirestore.instance.collection('Users').get();
    setState(() {
      employees = querySnapshot.docs
          .map((doc) => Employee(
                nombres: doc['Nombre'] ?? '',
                apellidos: doc['Apellidos'] ?? '',
                email: doc['email'] ?? '',
                telefono: doc['Telefono'] ?? '',
                role: doc['Role'] ?? 'Vendedor',
                fechaIngreso: doc['createdAt'] ?? '',
              ))
          .toList();
    });
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
        title: Text('Administrar Roles', style: TextStyle(color: dark)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Administrar Roles',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: dark),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add description',
                style: TextStyle(fontSize: 14, color: Colors.blue),
              ),
              const SizedBox(height: 24),
              _buildForm(),
              const SizedBox(height: 32),
              _buildUserTable(),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildForm() {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Formulario de Empleado',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: dark),
            ),
            const SizedBox(height: 24),
            _buildFormSection([
              _buildResponsiveRow([
                _buildCustomTextField(controller: _nombresController, label: 'Nombres', required: true),
                _buildCustomTextField(controller: _apellidosController, label: 'Apellidos', required: true),
              ]),
              const SizedBox(height: 16),
              _buildResponsiveRow([
                _buildCustomTextField(controller: _emailController, label: 'Email', hintText: 'email@dominio.com', required: true),
                _buildCustomTextField(controller: _telefonoController, label: 'Teléfono', hintText: '09-1234-5678'),
              ]),
              const SizedBox(height: 16),
              _buildResponsiveRow([
                //_buildDropdown(),
                _buildDatePicker(),
              ]),
              const SizedBox(height: 32),
              // Center(
              //   child: ElevatedButton(
              //     onPressed: _submitForm,
              //     style: ElevatedButton.styleFrom(
              //       primary: Colors.blue[700],
              //       padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(8),
              //       ),
              //     ),
              //     child: Text('Guardar', style: TextStyle(color: Colors.white, fontSize: 16)),
              //   ),
              // ),
            ]),
          ],
        ),
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
          const Text(
            'Lista de Empleados',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                DataColumn2(
                  label: Text('Nombres', style: TextStyle(fontWeight: FontWeight.bold)),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text('Apellidos', style: TextStyle(fontWeight: FontWeight.bold)),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text('Teléfono', style: TextStyle(fontWeight: FontWeight.bold)),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text('Role', style: TextStyle(fontWeight: FontWeight.bold)),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text('Fecha Ingreso', style: TextStyle(fontWeight: FontWeight.bold)),
                  size: ColumnSize.M,
                ),
              ],
              rows: employees.map((employee) => DataRow2(
                cells: [
                  DataCell(Text(employee.nombres)),
                  DataCell(Text(employee.apellidos)),
                  DataCell(Text(employee.email)),
                  DataCell(Text(employee.telefono)),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  DataCell(Text(DateFormat('dd/MM/yyyy').format(employee.fechaIngreso))),
                ],
              )).toList(),
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
    case 'manager':
      return Colors.green[400]!;
    case 'employee':
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

  Widget _buildEmployeeList(String role) {
    final roleEmployees = employees.where((employee) => employee.role == role).toList();
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: roleEmployees.length,
      itemBuilder: (context, index) {
        final employee = roleEmployees[index];
        return ListTile(
          title: Text('${employee.nombres} ${employee.apellidos}'),
          subtitle: Text(employee.email),
          trailing: Text(employee.fechaIngreso.toString()),
        );
      },
    );
  }

  Widget _buildFormSection(List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  Widget _buildResponsiveRow(List<Widget> children) {
    return Row(
      children: children.map((child) => Expanded(child: child)).toList(),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    bool required = false,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey[100],
          ),
          validator: required
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es requerido';
                  }
                  return null;
                }
              : null,
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Role',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey[100],
          ),
          value: selectedRole,
          items: ['Admin', 'Manager', 'Employee']
              .map((role) => DropdownMenuItem(
                    value: role,
                    child: Text(role),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              selectedRole = value!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: TextFormField(
          controller: _fechaIngresoController,
          decoration: InputDecoration(
            labelText: 'Fecha Ingreso',
            hintText: 'dd/mm/yyyy',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey[100],
            suffixIcon: const Icon(Icons.calendar_today),
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
              setState(() {
                _fechaIngresoController.text = formattedDate;
              });
            }
          },
        ),
      ),
    );
  }
}