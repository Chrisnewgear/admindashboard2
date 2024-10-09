import 'package:cloud_firestore/cloud_firestore.dart';

class Clients {
  final String nombres;
  final String apellidos;
  final String email;
  final String telefono;
  final String direccion;
  final String codigo;
  final DateTime fechaIngreso;
  final String empresa;
  final String codVendedor;

  Clients({
    required this.nombres,
    required this.apellidos,
    required this.email,
    required this.telefono,
    required this.direccion,
    this.codigo = '',
    required this.fechaIngreso,
    required this.empresa,
    required this.codVendedor,
  });

  factory Clients.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Clients(
      nombres: data['Nombre'] ?? '',
      apellidos: data['Apellidos'] ?? '',
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