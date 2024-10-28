import 'package:cloud_firestore/cloud_firestore.dart';

class Cliente {
  final String nombre;
  final String apellido;
  final String email;
  final String telefono;
  final String direccion;
  final String codigo;
  final DateTime fechaIngreso;
  final String empresa;
  final String codVendedor;

  Cliente({
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.telefono,
    required this.direccion,
    this.codigo = '',
    required this.fechaIngreso,
    required this.empresa,
    required this.codVendedor,
  });

  factory Cliente.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Cliente(
      nombre: data['Nombre'] ?? '',
      apellido: data['Apellidos'] ?? '',
      email: data['email'] ?? '',
      telefono: data['Telefono'] ?? '',
      direccion: data['Direccion'] ?? '',
      codigo: data['Codigo'] ?? '',
      empresa: data['Empresa'] ?? '',
      codVendedor: data['CodVendedor'] ?? '',
      fechaIngreso: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}