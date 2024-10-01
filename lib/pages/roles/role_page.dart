import 'package:admindashboard/models/employee.dart';
import 'package:flutter/material.dart';
import 'package:admindashboard/constants/style.dart';

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
              _buildAccordions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: _buildFormSection([
        _buildResponsiveRow([
          _buildCustomTextField(controller: _nombresController, label: 'Nombres', required: true),
          _buildCustomTextField(controller: _apellidosController, label: 'Apellidos', required: true),
        ]),
        _buildResponsiveRow([
          _buildCustomTextField(controller: _emailController, label: 'Email', hintText: 'email@dominio.com', required: true),
          _buildCustomTextField(controller: _telefonoController, label: 'Telefono', hintText: '09-1234-5678'),
        ]),
        _buildResponsiveRow([
          _buildDropdown(),
          _buildCustomTextField(controller: _fechaIngresoController, label: 'Fecha Ingreso', hintText: 'dd/mm/yyyy'),
        ]),
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: active,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            ),
            child: Text('Guardar', style: TextStyle(color: light)),
          ),
        ),
      ]),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newEmployee = Employee(
        nombres: _nombresController.text,
        apellidos: _apellidosController.text,
        email: _emailController.text,
        telefono: _telefonoController.text,
        role: selectedRole,
        fechaIngreso: _fechaIngresoController.text,
      );

      setState(() {
        employees.add(newEmployee);
      });

      _clearForm();
    }
  }

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

  Widget _buildAccordions() {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          roles[index] = roles[index] == 'Vendedor' ? 'Supervisor' : 'Vendedor';
        });
      },
      children: roles.map<ExpansionPanel>((String role) {
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(role, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            );
          },
          body: _buildEmployeeList(role),
          isExpanded: true,
        );
      }).toList(),
    );
  }

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
          trailing: Text(employee.fechaIngreso),
        );
      },
    );
  }

  Widget _buildFormSection(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: lightGrey),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(children: children),
    );
  }

  Widget _buildResponsiveRow(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return constraints.maxWidth > 600
            ? Row(
                children: children.map((child) => Expanded(child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: child,
                ))).toList(),
              )
            : Column(children: children);
      },
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label + (required ? '*' : ''),
          hintText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        validator: required
            ? (value) => value!.isEmpty ? 'This field is required' : null
            : null,
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Role',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        value: selectedRole,
        items: roles.map((String role) {
          return DropdownMenuItem<String>(
            value: role,
            child: Text(role),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedRole = newValue!;
          });
        },
      ),
    );
  }
}