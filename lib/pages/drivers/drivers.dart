import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:admindashboard/models/visits.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this import

class VisitsManagementWidget extends StatefulWidget {
  const VisitsManagementWidget({super.key});

  @override
  _VisitsManagementWidgetState createState() => _VisitsManagementWidgetState();
}

class _VisitsManagementWidgetState extends State<VisitsManagementWidget> {
  List<Visitas> visitas = [];

  final TextEditingController _accionesController = TextEditingController();
  final TextEditingController _codVendedorController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();
  final TextEditingController _notasController = TextEditingController();
  final TextEditingController _prodServicioController = TextEditingController();
  final TextEditingController _propVisitaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserCodeAndVisits();
  }

  Future<void> _loadUserCodeAndVisits() async {
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
      await _loadVisits();
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

  Future<void> _loadVisits() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('Visits').get();
      setState(() {
        visitas = querySnapshot.docs
            .map((doc) => Visitas.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading visits: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar las visitas: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  // Future<String> _getNextUserCode() async {
  //   Random random = Random();
  //   String code = '';
  //   bool isUnique = false;

  //   while (!isUnique) {
  //     // Generar un número aleatorio de 6 dígitos
  //     int randomNumber = random.nextInt(900000) + 100000; // Asegura 6 dígitos
  //     code = 'USR$randomNumber';

  //     // Verificar si el código ya existe en Firebase
  //     QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //         .collection('Users')
  //         .where('Codigo', isEqualTo: code)
  //         .limit(1)
  //         .get();

  //     if (querySnapshot.docs.isEmpty) {
  //       isUnique = true; // El código es único
  //     }
  //   }

  //   return code;
  // }

  Future<void> _saveOrUpdateVisit(Visitas? existingVisit) async {
    try {
      final visitData = {
        'Acciones': _accionesController.text,
        'CodVendedor': _codVendedorController.text,
        'Hora': _horaController.text,
        'Notas': _notasController.text,
        'ProductoServicio': _prodServicioController.text,
        'PropositoVisita': _propVisitaController.text,
        'Fecha': Timestamp.fromDate(
            DateFormat('dd/MM/yyyy').parse(_fechaController.text)),
      };

      if (existingVisit == null) {
        // Create a new visit
        await FirebaseFirestore.instance.collection('Visits').add(visitData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Visita agendada exitosamente')),
        );
      } else {
        // Update existing visit
        await FirebaseFirestore.instance
            .collection('Visits')
            .doc(existingVisit
                .id) // Assuming you have an 'id' field in your Visitas model
            .update(visitData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Visita actualizada exitosamente')),
        );
      }

      // Reload the visits list
      await _loadVisits();

      // Clear the form fields
      _clearFormFields();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearFormFields() {
    _accionesController.clear();
    _horaController.clear();
    _notasController.clear();
    _prodServicioController.clear();
    _propVisitaController.clear();
    _fechaController.clear();
  }

  void showClientVisitFormDialog(BuildContext context, Visitas? visita) {
    final _formKey = GlobalKey<FormState>();

    if (visita != null) {
      _accionesController.text = visita.acciones;
      _prodServicioController.text = visita.productoServicio;
      _propVisitaController.text = visita.propVisita;
      _notasController.text = visita.notas;
      _horaController.text = visita.hora;
      _fechaController.text = DateFormat('dd/MM/yyyy').format(visita.fecha);
    } else {
      _accionesController.clear();
      _prodServicioController.clear();
      _propVisitaController.clear();
      _notasController.clear();
      _horaController.clear();
      _fechaController.clear();
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      visita == null ? 'Nueva Visita' : 'Editar Visita',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          bool isLargeScreen = constraints.maxWidth > 600;
                          return Column(
                            children: [
                              isLargeScreen
                                  ? Row(
                                      children: [
                                        Expanded(
                                            child: _buildTextField(
                                                _accionesController,
                                                'Acciones')),
                                        const SizedBox(width: 20),
                                        Expanded(
                                            child: _buildTextField(
                                                _codVendedorController,
                                                'Cod. Vendedor')),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        _buildTextField(
                                            _accionesController, 'Acciones'),
                                        const SizedBox(height: 15),
                                        _buildTextField(_codVendedorController,
                                            'Cod. Vendedor'),
                                      ],
                                    ),
                              const SizedBox(height: 15),
                              isLargeScreen
                                  ? Row(
                                      children: [
                                        Expanded(
                                            child: _buildTextField(
                                                _prodServicioController,
                                                'Producto/Servicio')),
                                        const SizedBox(width: 20),
                                        Expanded(
                                            child: _buildTextField(
                                                _propVisitaController,
                                                'Propósito de Visita')),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        _buildTextField(_prodServicioController,
                                            'Producto/Servicio'),
                                        const SizedBox(height: 15),
                                        _buildTextField(_propVisitaController,
                                            'Propósito de Visita'),
                                      ],
                                    ),
                              const SizedBox(height: 15),
                              isLargeScreen
                                  ? Row(
                                      children: [
                                        Expanded(
                                            child: _buildDatePicker(context,
                                                _fechaController, 'Fecha')),
                                        const SizedBox(width: 20),
                                        Expanded(
                                            child: _buildTimePicker(context,
                                                _horaController, 'Hora')),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        _buildDatePicker(
                                            context, _fechaController, 'Fecha'),
                                        const SizedBox(height: 15),
                                        _buildTimePicker(
                                            context, _horaController, 'Hora'),
                                      ],
                                    ),
                              const SizedBox(height: 15),
                              _buildTextField(_notasController, 'Notas',
                                  maxLines: 3),
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
                              _saveOrUpdateVisit(visita);
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.save, color: Colors.white),
                              SizedBox(width: 5),
                              Text('Guardar',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
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

  Widget _buildDatePicker(
      BuildContext context, TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      readOnly: true,
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2025),
        );
        if (picked != null) {
          controller.text = DateFormat('dd/MM/yyyy').format(picked);
        }
      },
      validator: (value) => value!.isEmpty ? 'Seleccione una fecha' : null,
    );
  }

  Widget _buildTimePicker(
      BuildContext context, TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      readOnly: true,
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (picked != null) {
          controller.text = picked.format(context);
        }
      },
      validator: (value) => value!.isEmpty ? 'Seleccione una hora' : null,
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      maxLines: maxLines,
      validator: (value) => value!.isEmpty ? 'Este campo es requerido' : null,
    );
  }

  @override
  void dispose() {
    _accionesController.dispose();
    _codVendedorController.dispose();
    _fechaController.dispose();
    _horaController.dispose();
    _notasController.dispose();
    _prodServicioController.dispose();
    _propVisitaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Administrar Roles'),
      // ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Agendar Visitas',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mis visitas',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () => showClientVisitFormDialog(context, null),
                  child: const Text('Agendar Visita'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            visitas.isEmpty
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
                            child: Text('Acciones',
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
                            child: Text('Hora',
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
                            child: Text('Notas',
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
                            child: Text('Producto/Servicio',
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
                            child: Text('Proposito Visita',
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
                            child: Text('Fecha',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                )),
                          ),
                          size: ColumnSize.L,
                        ),
                      ],
                      rows: visitas
                          .map((visita) => DataRow2(
                                cells: [
                                  DataCell(
                                      Center(child: Text(visita.codVendedor))),
                                  DataCell(
                                      Center(child: Text(visita.acciones))),
                                  DataCell(Center(child: Text(visita.hora))),
                                  DataCell(Center(child: Text(visita.notas))),
                                  DataCell(Center(
                                      child: Text(visita.productoServicio))),
                                  DataCell(
                                      Center(child: Text(visita.propVisita))),
                                  DataCell(
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(DateFormat('dd/MM/yyyy')
                                            .format(visita.fecha)),
                                        PopupMenuButton<String>(
                                          onSelected: (value) {
                                            if (value == 'Eliminar') {
                                              _deleteVisit(visita);
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
                                    showClientVisitFormDialog(context, visita),
                              ))
                          .toList(),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteVisit(Visitas visita) async {
    // Mostrar un diálogo de confirmación
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text('¿Está seguro de que desea eliminar la visita?'),
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
        // Eliminar el documento directamente usando su ID
        await FirebaseFirestore.instance
            .collection('Visits')
            .doc(visita.id)
            .delete();

        // Actualizar la lista de visitas localmente
        setState(() {
          visitas.removeWhere((v) => v.id == visita.id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Visita eliminada con éxito')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar la visita: $e')),
        );
      }
    }
  }
}
