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
  String selectedPurpose = 'Venta';
  List<String> purpose = ['Venta', 'Seguimiento', 'Renovación', 'Resolución'];
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
          String codVendedor = userDoc.get('Codigo') ?? '';
          setState(() {
            _codVendedorController.text = codVendedor;
          });

          // Load visits corresponding to the user's code
          await _loadVisits(codVendedor);
        }
      }
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

  Future<void> _loadVisits(String codVendedor) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Visits')
          .where('CodVendedor',
              isEqualTo: codVendedor) // Filtrar por CodVendedor
          .get();

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
      // Obtener el usuario actualmente logueado
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No hay ningún usuario logueado.');
      }

      // Obtener el código del vendedor y el UserId
      final userId = user.uid;
      final codVendedor = _codVendedorController.text;

      // Datos de la visita a guardar o actualizar
      final visitData = {
        'Acciones': _accionesController.text,
        'CodVendedor': codVendedor, // Código del vendedor logueado
        'Hora': _horaController.text,
        'Notas': _notasController.text,
        'ProductoServicio': _prodServicioController.text,
        'PropositoVisita': selectedPurpose,
        'UserId': userId, // UserId del usuario logueado
        'Fecha': Timestamp.fromDate(
            DateFormat('dd/MM/yyyy').parse(_fechaController.text)),
      };

      if (existingVisit == null) {
        // Crear una nueva visita
        await FirebaseFirestore.instance.collection('Visits').add(visitData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Visita agendada exitosamente')),
        );
      } else {
        // Actualizar visita existente
        await FirebaseFirestore.instance
            .collection('Visits')
            .doc(existingVisit
                .id) // Suponiendo que tienes un campo 'id' en Visitas
            .update(visitData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Visita actualizada exitosamente')),
        );
      }

      // Recargar la lista de visitas filtradas por CodVendedor
      await _loadVisits(codVendedor);

      // Limpiar los campos del formulario
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
    final formKey = GlobalKey<FormState>();
    final ValueNotifier<bool> isEditable = ValueNotifier<bool>(visita == null);

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
      selectedPurpose = 'Venta'; // Reset selectedPurpose();
      _notasController.clear();
      _horaController.clear();
      _fechaController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
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
                      key: formKey,
                      child: ValueListenableBuilder<bool>(
                        valueListenable: isEditable,
                        builder: (context, editable, _) {
                          bool isLargeScreen = constraints.maxWidth > 600;
                          return Column(
                            children: [
                              _buildResponsiveRow(isLargeScreen, [
                                _buildInputField(
                                    _codVendedorController, 'Cod. Vendedor',
                                    enabled: editable),
                                _buildInputField(
                                    _accionesController, 'Acciones',
                                    enabled: editable),
                              ]),
                              _buildResponsiveRow(isLargeScreen, [
                                _buildInputField(_prodServicioController,
                                    'Producto/Servicio',
                                    enabled: editable),
                                _buildDropdown(selectedPurpose,
                                    (String? newValue) {
                                  setState(() {
                                    selectedPurpose = newValue!;
                                  });
                                }, enabled: editable),
                              ]),
                              _buildResponsiveRow(isLargeScreen, [
                                _buildDatePicker(context, _fechaController,
                                    'Fecha de Ingreso',
                                    enabled: editable),
                                _buildTimePicker(
                                    context, _horaController, 'Hora',
                                    enabled: false),
                              ]),
                              _buildResponsiveRow(isLargeScreen, [
                                _buildNotesField(_notasController, 'Notas',
                                    enabled: editable),
                              ]),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Botón de Editar solo se muestra cuando se está editando un cliente existente
                        if (visita != null)
                          ElevatedButton(
                            onPressed: () {
                              isEditable.value = !isEditable.value;
                            },
                            child: ValueListenableBuilder<bool>(
                              valueListenable: isEditable,
                              builder: (context, editable, _) {
                                return Text(
                                  editable ? 'Cancelar Edición' : 'Editar',
                                );
                              },
                            ),
                          ),
                        const Spacer(),
                        // Botones de Cancelar y Guardar
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              _saveOrUpdateVisit(visita);
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text(
                            'Guardar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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
      {bool isEmail = false, required bool enabled}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        enabled: enabled,
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

  Widget _buildDatePicker(
      BuildContext context, TextEditingController controller, String label,
      {required bool enabled}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        enabled: enabled,
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
          suffixIcon: Icon(
            Icons.calendar_today_outlined, // Ícono más moderno
            color: enabled ? Colors.grey[600] : Colors.grey[400] // Cambiar color acorde a la paleta
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

  Widget _buildDropdown(String currentValue, Function(String?) onChanged,
      {required bool enabled}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: currentValue,
        items: ['Venta', 'Seguimiento', 'Renovación', 'Resolución']
            .map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: enabled ? onChanged : null,
        decoration: InputDecoration(
          labelText: 'Propósito',
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
            return 'Por favor seleccione un motivo de visita';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTimePicker(
      BuildContext context, TextEditingController controller, String label,
      {required bool enabled}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        enabled: enabled,
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
          floatingLabelBehavior: FloatingLabelBehavior.always,
          suffixIcon: Icon(Icons.access_time,
              color: enabled ? Colors.grey[600] : Colors.grey[400]),
        ),
        readOnly: true,
        onTap: enabled
            ? () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null) {
                  controller.text = picked.format(context);
                }
              }
            : null,
        validator: (value) => value!.isEmpty ? 'Seleccione una hora' : null,
      ),
    );
  }

  Widget _buildNotesField(TextEditingController controller, String label,
      {required bool enabled}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        enabled: enabled,
        controller: controller,
        maxLines: null, // Permite múltiples líneas
        keyboardType: TextInputType
            .multiline, // Configura el teclado para entrada de texto largo
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
        // Sin validación porque no es un campo obligatorio
      ),
    );
  }

  // Widget _buildTextField(TextEditingController controller, String label,
  //     {int maxLines = 1}) {
  //   return TextFormField(
  //     controller: controller,
  //     decoration: InputDecoration(labelText: label),
  //     maxLines: maxLines,
  //     validator: (value) => value!.isEmpty ? 'Este campo es requerido' : null,
  //   );
  // }

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
      color: Colors.white70,
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
                        // DataColumn2(
                        //   label: Center(
                        //     child: Text('Cod. Vendedor',
                        //         style: TextStyle(
                        //           fontSize: 16,
                        //           fontWeight: FontWeight.bold,
                        //           color: Colors.blue,
                        //         )),
                        //   ),
                        //   size: ColumnSize.L,
                        // ),
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
                        // DataColumn2(
                        //   label: Center(
                        //     child: Text('Hora',
                        //         style: TextStyle(
                        //           fontSize: 16,
                        //           fontWeight: FontWeight.bold,
                        //           color: Colors.blue,
                        //         )),
                        //   ),
                        //   size: ColumnSize.L,
                        // ),
                        // DataColumn2(
                        //   label: Center(
                        //     child: Text('Notas',
                        //         style: TextStyle(
                        //           fontSize: 16,
                        //           fontWeight: FontWeight.bold,
                        //           color: Colors.blue,
                        //         )),
                        //   ),
                        //   size: ColumnSize.L,
                        // ),
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
                                  // DataCell(
                                  //     Center(child: Text(visita.codVendedor))),
                                  DataCell(
                                      Center(child: Text(visita.acciones))),
                                  // DataCell(Center(child: Text(visita.hora))),
                                  // DataCell(Center(child: Text(visita.notas))),
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
