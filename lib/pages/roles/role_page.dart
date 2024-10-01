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
  bool isManagerApproved = false;
  bool hasAssignedDelegates = false;

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
          child: Form(
            key: _formKey,
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
                _buildFormSection([
                  _buildResponsiveRow([
                    _buildCustomTextField(label: 'Nombres', required: true),
                    _buildCustomTextField(label: 'Apellidos'),
                  ]),
                  _buildResponsiveRow([
                    _buildCustomTextField(label: 'Email', hintText: 'email@dominio.com'),
                    _buildCustomTextField(label: 'Telefono', hintText: '09-1234-5678'),
                  ]),
                  _buildResponsiveRow([
                    _buildDropdown(),
                    _buildCustomTextField(label: 'Fecha Ingreso', hintText: 'dd/mm/yyyy'),
                    // _buildRadioButtons('Manager Approved', isManagerApproved, (value) {
                    //   setState(() => isManagerApproved = value!);
                    // }),
                  ]),
                  // _buildResponsiveRow([
                  //   _buildRadioButtons('Assigned Delegates', hasAssignedDelegates, (value) {
                  //     setState(() => hasAssignedDelegates = value!);
                  //   }),
                  //   _buildCustomTextField(label: 'PL Balance'),
                  // ]),
                ]),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Process data
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: active,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                    child: Text('Submit', style: TextStyle(color: light)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
    required String label,
    String? hintText,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
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

  Widget _buildRadioButtons(String label, bool value, Function(bool?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: dark)),
          Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: value,
                onChanged: onChanged,
              ),
              const Text('Yes'),
              Radio<bool>(
                value: false,
                groupValue: value,
                onChanged: onChanged,
              ),
              const Text('No'),
            ],
          ),
        ],
      ),
    );
  }
}