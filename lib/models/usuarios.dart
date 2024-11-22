import 'package:cloud_firestore/cloud_firestore.dart';

// class Usuario {
//   final String nombres;
//   final String apellidos;
//   final String email;
//   final String telefono;
//   final String role;
//   final String codigo;
//   final DateTime fechaIngreso;

//   Usuario({
//     required this.nombres,
//     required this.apellidos,
//     required this.email,
//     required this.telefono,
//     required this.role,
//     this.codigo = '',
//     required this.fechaIngreso,
//   });

//   factory Usuario.fromFirestore(DocumentSnapshot doc) {
//     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//     return Usuario(
//       nombres: data['Nombre'] ?? '',
//       apellidos: data['Apellidos'] ?? '',
//       email: data['email'] ?? '',
//       telefono: data['Telefono'] ?? '',
//       role: data['Role'] ?? 'None',
//       codigo: data['Codigo'] ?? '',
//       fechaIngreso: data['createdAt'] != null
//           ? (data['createdAt'] as Timestamp).toDate()
//           : DateTime.now(),
//     );
//   }
// }

class Usuario {
  final String nombres;
  final String apellidos;
  final String email;
  final String telefono;
  final String role;
  final String codigo;
  final DateTime fechaIngreso;

  Usuario({
    required this.nombres,
    required this.apellidos,
    required this.email,
    required this.telefono,
    required this.role,
    this.codigo = '',
    required this.fechaIngreso,
  });

  factory Usuario.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Usuario(
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
