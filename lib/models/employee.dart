import 'package:cloud_firestore/cloud_firestore.dart';

class Employee {
  final String nombres;
  final String apellidos;
  final String email;
  final String telefono;
  final String role;
  final String codigo;
  final DateTime fechaIngreso;

  Employee({
    required this.nombres,
    required this.apellidos,
    required this.email,
    required this.telefono,
    required this.role,
    this.codigo = '',
    required this.fechaIngreso,
  });

  factory Employee.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Employee(
      nombres: data['Nombre'] ?? '',
      apellidos: data['Apellidos'] ?? '',
      email: data['email'] ?? '',
      telefono: data['Telefono'] ?? '',
      role: data['Role'] ?? 'None',
      codigo: data['Codigo'] ?? '',
      fechaIngreso: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}