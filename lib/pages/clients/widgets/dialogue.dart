import 'package:admindashboard/models/clients.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para la fecha
// Importa el modelo y cualquier otro paquete necesario

class ClientFormDialog extends StatefulWidget {
  final Clients? client;

  const ClientFormDialog({super.key, this.client});

  @override
  _ClientFormDialogState createState() => _ClientFormDialogState();
}

class _ClientFormDialogState extends State<ClientFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombresController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _empresaController = TextEditingController();
  final TextEditingController _fechaIngresoController = TextEditingController();

  String? selectedRole;

  @override
  void initState() {
    super.initState();
    if (widget.client != null) {
      _nombresController.text = widget.client!.nombres;
      _apellidosController.text = widget.client!.apellidos;
      _emailController.text = widget.client!.email;
      _telefonoController.text = widget.client!.telefono;
      _codigoController.text = widget.client!.codigo;
      _direccionController.text = widget.client!.direccion;
      _empresaController.text = widget.client!.empresa;
      _fechaIngresoController.text = DateFormat('dd/MM/yyyy').format(widget.client!.fechaIngreso);
      // selectedRole = widget.client!.role;
    }
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _codigoController.dispose();
    _direccionController.dispose();
    _empresaController.dispose();
    _fechaIngresoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          double modalWidth = constraints.maxWidth > 600
              ? constraints.maxWidth * 0.4
              : constraints.maxWidth * 0.9;

          return Container(
            width: modalWidth,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.client == null ? 'Nuevo Cliente' : 'Editar Cliente',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: _buildFormFields(context),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancelar', style: TextStyle(color: Colors.grey[600])),
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
                          _saveOrUpdateClient(widget.client);
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
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
  }

  Widget _buildFormFields(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isLargeScreen = constraints.maxWidth > 600;

        return Column(
          children: [
            isLargeScreen
                ? Row(
                    children: [
                      Expanded(child: _buildTextField(_nombresController, 'Nombres')),
                      const SizedBox(width: 20),
                      Expanded(child: _buildTextField(_apellidosController, 'Apellidos')),
                    ],
                  )
                : Column(
                    children: [
                      _buildTextField(_nombresController, 'Nombres'),
                      const SizedBox(height: 15),
                      _buildTextField(_apellidosController, 'Apellidos'),
                    ],
                  ),
            const SizedBox(height: 15),
            // Repite esto para cada fila de inputs
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isEmail = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese $label';
        }
        return null;
      },
    );
  }

  Widget _buildDatePicker(BuildContext context, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(labelText: 'Fecha de Ingreso'),
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          setState(() {
            controller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
          });
        }
      },
    );
  }

  Widget _buildDropdown(String? value, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      decoration: const InputDecoration(labelText: 'Rol'),
      items: ['Admin', 'Supervisor', 'Vendedor'].map((role) {
        return DropdownMenuItem<String>(
          value: role,
          child: Text(role),
        );
      }).toList(),
    );
  }

  void _saveOrUpdateClient(Clients? client) {
    // Lógica para guardar o actualizar cliente
  }
}
