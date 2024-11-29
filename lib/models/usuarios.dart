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

//   /// Método para convertir la clase Usuario en un mapa compatible con Firebase
//   Map<String, dynamic> toMap() {
//     return {
//       'Nombre': nombres,
//       'Apellidos': apellidos,
//       'email': email,
//       'Telefono': telefono,
//       'Role': role,
//       'Codigo': codigo,
//       'createdAt': fechaIngreso,
//     };
//   }
// }


class Usuario {
  final String nombres;
  final String apellidos;
  final String email;
  final String telefono;
  final String role;
  final String codigo;
  final String codigoSupervisor;
  final DateTime fechaIngreso;
  final bool asignado;
  final List<Usuario> myTeam = [];

  Usuario({
    required this.nombres,
    required this.apellidos,
    required this.email,
    required this.telefono,
    required this.role,
    this.codigo = '',
    this.codigoSupervisor = '',
    required this.fechaIngreso,
    this.asignado = false,
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
      codigoSupervisor: data['CodigoSupervisor'] ?? '',
      fechaIngreso: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      asignado: data['asignado'] ?? false
    );
  }

  /// Método para convertir la clase Usuario en un mapa compatible con Firebase
  Map<String, dynamic> toMap() {
    return {
      'Nombre': nombres,
      'Apellidos': apellidos,
      'email': email,
      'Telefono': telefono,
      'Role': role,
      'Codigo': codigo,
      'CodigoSupervisor': codigoSupervisor,
      'createdAt': fechaIngreso,
      'Asignado': asignado,
    };
  }

  /// Método para crear un objeto Usuario a partir de un mapa
  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      nombres: map['Nombre'] ?? '',
      apellidos: map['Apellidos'] ?? '',
      email: map['email'] ?? '',
      telefono: map['Telefono'] ?? '',
      role: map['Role'] ?? 'None',
      codigo: map['Codigo'] ?? '',
      codigoSupervisor: map['CodigoSupervisor'] ?? '',
      fechaIngreso: map['createdAt'] != null
          ? (map['createdAt'] is Timestamp ? (map['createdAt'] as Timestamp).toDate() : map['createdAt'] as DateTime)
          : DateTime.now(),
      asignado: map['asignado'] ?? false
    );
  }
}
