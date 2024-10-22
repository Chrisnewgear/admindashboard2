import 'package:admindashboard/pages/visits/visitas_paginated_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:admindashboard/models/visits.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class VisitsManagementWidget extends StatefulWidget {
  const VisitsManagementWidget({super.key});

  @override
  _VisitsManagementWidgetState createState() => _VisitsManagementWidgetState();
}

class _VisitsManagementWidgetState extends State<VisitsManagementWidget> {
  bool isLoading = false;
  String selectedPurpose = 'Venta';
  List<String> purpose = ['Venta', 'Seguimiento', 'Renovación', 'Resolución'];
  List<Visitas> visitas = [];
  String currentVendorCode = '';

  final TextEditingController _accionesController = TextEditingController();
  final TextEditingController _codVendedorController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();
  final TextEditingController _notasController = TextEditingController();
  final TextEditingController _prodServicioController = TextEditingController();
  final TextEditingController _propVisitaController = TextEditingController();
  final TextEditingController _nombreClienteController =
      TextEditingController();

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
          String userCode = userDoc.get('Codigo') ?? '';
          setState(() {
            _codVendedorController.text = userCode;
            currentVendorCode = _codVendedorController.text;
          });

          // Load visits corresponding to the user's code
          await _loadVisits(currentUser.uid);
        }
      }
    } catch (e) {
      // if (kDebugMode) {
      //   print('Error loading user code and visits: $e');
      // }
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
    setState(() {
      isLoading = true; // Activar loading al inicio de la carga
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('Visits')
          .where('UserId', isEqualTo: codVendedor)
          .get();

      setState(() {
        visitas = querySnapshot.docs
            .map((doc) => Visitas.fromFirestore(doc))
            .toList();
        isLoading = false; // Desactivar loading cuando los datos están listos
      });
    } catch (e) {
      setState(() {
        isLoading = false; // Desactivar loading incluso si hay error
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar las visitas: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveOrUpdateVisit(
      BuildContext context, Visitas? existingVisit) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      // Mostrar el loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: SpinKitFadingCircle(
              color: Colors.blue,
              size: 50.0,
            ),
          );
        },
      );

      // Obtener el usuario actual y la ubicación
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No hay ningún usuario logueado.');
      }
      GeoPoint? geoPoint = await _getCurrentLocation(context);
      if (geoPoint == null) {
        throw Exception('No se pudo obtener la ubicación actual.');
      }

      final visitData = {
        'Acciones': _accionesController.text,
        'CodVendedor': currentVendorCode,
        'Hora': _horaController.text,
        'Notas': _notasController.text,
        'ProductoServicio': _prodServicioController.text,
        'PropositoVisita': selectedPurpose,
        'NombreCliente': _nombreClienteController.text,
        'UserId': user.uid,
        'Fecha': Timestamp.fromDate(
            DateFormat('dd/MM/yyyy').parse(_fechaController.text)),
        'Location': geoPoint,
        'updatedAt': Timestamp.now(),
      };

      // Guardar o actualizar la visita en Firestore
      if (existingVisit == null) {
        visitData['createdAt'] = Timestamp.now();
        await FirebaseFirestore.instance.collection('Visits').add(visitData);
      } else {
        await FirebaseFirestore.instance
            .collection('Visits')
            .doc(existingVisit.id)
            .update(visitData);
      }

      await _loadVisits(user.uid);
      _clearFormFields();

      // Cerrar el loading y mostrar el SnackBar
      Navigator.of(context).pop();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(existingVisit == null
              ? 'Visita creada exitosamente'
              : 'Visita actualizada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Cerrar el loading y mostrar el SnackBar con el error
      Navigator.of(context).pop();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  // void _showErrorMessage(BuildContext context, String errorMessage) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text('Error: $errorMessage'),
  //       backgroundColor: Colors.red,
  //     ),
  //   );
  // }

  Future<GeoPoint?> _getCurrentLocation(BuildContext context) async {
    try {
      // Verificar permisos
      bool serviceEnabled;
      try {
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
      } catch (e) {
        print("Error al verificar el servicio de ubicación: $e");
        _showSnackBar(context,
            'Error al verificar el servicio de ubicación. Por favor, reinicia la aplicación.');
        return null;
      }

      if (!serviceEnabled) {
        _showSnackBar(
            context, 'Los servicios de ubicación están desactivados.');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar(context, 'Permisos de ubicación denegados');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar(context,
            'Los permisos de ubicación están permanentemente denegados');
        return null;
      }

      // Obtener la posición usando LocationSettings
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      return GeoPoint(position.latitude, position.longitude);
    } catch (e) {
      print("Error detallado al obtener la ubicación: $e");
      _showSnackBar(context,
          'Error al obtener la ubicación. Por favor, verifica los permisos e intenta de nuevo.');
      return null;
    }
  }

  void _showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  void _clearFormFields() {
    _accionesController.clear();
    _horaController.clear();
    _notasController.clear();
    _prodServicioController.clear();
    _propVisitaController.clear();
    _fechaController.clear();
    _nombreClienteController.clear();
  }

  void _showClientVisitFormDialog(BuildContext context, Visitas? visita) {
    final formKey = GlobalKey<FormState>();
    final ValueNotifier<bool> isEditable = ValueNotifier<bool>(visita == null);

    if (visita != null) {
      _accionesController.text = visita.acciones;
      _prodServicioController.text = visita.productoServicio;
      _propVisitaController.text = visita.propVisita;
      _notasController.text = visita.notas;
      _nombreClienteController.text = visita.nombreCliente;
      _horaController.text = visita.hora;
      _fechaController.text = DateFormat('dd/MM/yyyy').format(visita.fecha);
    } else {
      _accionesController.clear();
      _prodServicioController.clear();
      selectedPurpose = 'Venta';
      _notasController.clear();
      _nombreClienteController.clear();
      _horaController.text = DateFormat('HH:mm').format(DateTime.now());
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
              double modalWidth;
              if (constraints.maxWidth > 927) {
                modalWidth = constraints.maxWidth * 0.4;
              } else if (constraints.maxWidth > 681) {
                modalWidth = constraints.maxWidth * 0.7;
              } else {
                modalWidth = constraints.maxWidth * 0.9;
              }

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
                          bool isLargeScreen = constraints.maxWidth > 986;
                          return Column(
                            children: [
                              _buildResponsiveRow(isLargeScreen, [
                                _buildInputField(
                                    _nombreClienteController, 'Nombre Cliente',
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
                                    enabled: false),
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
                        if (visita != null)
                          ValueListenableBuilder<bool>(
                            valueListenable: isEditable,
                            builder: (context, editable, _) {
                              return ElevatedButton.icon(
                                onPressed: () {
                                  isEditable.value = !isEditable
                                      .value; // Cambia el estado de edición
                                },
                                icon: editable
                                    ? const Icon(Icons
                                        .edit_off) // Ícono cuando está habilitado
                                    : const Icon(Icons
                                        .edit), // Ícono cuando está deshabilitado
                                label: MediaQuery.of(context).size.width < 400
                                    ? const Text(
                                        '') // Texto vacío si el ancho es menor a 400px
                                    : const Text(
                                        'Editar'), // Mostrar texto en pantallas más grandes
                              );
                            },
                          ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.cancel),
                          label: MediaQuery.of(context).size.width < 400
                              ? const Text(
                                  '') // Texto vacío si el ancho es menor a 400px
                              : const Text(
                                  'Cancelar'), // Mostrar texto en pantallas más grandes
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
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
                              _saveOrUpdateVisit(context, visita);
                              Navigator.of(context).pop();
                            }
                          },
                          icon: const Icon(
                            Icons.save,
                            color: Colors.white,
                          ),
                          label: MediaQuery.of(context).size.width < 400
                              ? const Text(
                                  '') // Texto vacío si el ancho es menor a 400px
                              : const Text('Guardar',
                                  style: TextStyle(
                                      color: Colors
                                          .white)), // Mostrar texto en pantallas más grandes
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
          suffixIcon: Icon(Icons.calendar_today_outlined, // Ícono más moderno
              color: enabled
                  ? Colors.grey[600]
                  : Colors.grey[400] // Cambiar color acorde a la paleta
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
        enabled:
            false, // Cambiar a false para que el usuario no pueda modificar la hora
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
          suffixIcon: Icon(Icons.access_time, color: Colors.grey[400]),
        ),
        readOnly: true,
        validator: (value) => value!.isEmpty ? 'Hora requerida' : null,
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
    _nombreClienteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Agendar Visitas',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ResponsiveVisitasTable(
                visitas: visitas,
                deleteVisit: (visita) => _deleteVisit(visita),
                showClientVisitFormDialog: (context, visita) =>
                    _showClientVisitFormDialog(context, visita),
                isLoading: isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteVisit(Visitas visita) async {
    // Mostrar un diálogo de confirmación
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            width: 400, // Ajusta el tamaño según tu diseño
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Confirmar eliminación',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  '¿Está seguro de que desea eliminar esta visita?',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.red, // Color del botón "Guardar"
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      child: const Text('Eliminar',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
