import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  final String nombres;
  final String apellidos;
  final String email;
  final String telefono;
  final String role;
  final String codigo;
  String codigoSupervisor;
  final DateTime fechaIngreso;
  bool asignado;
  final List<Usuario> myTeam = [];
  final String? imageUrl; // Nueva propiedad imageUrl (opcional)

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
    this.imageUrl, // Se agrega como parámetro opcional en el constructor
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
      asignado: data['asignado'] ?? false,
      imageUrl: data['imageUrl'], // Obtener imageUrl de Firestore si existe
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
      'imageUrl': imageUrl, // Agregar la propiedad imageUrl al mapa
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      nombres: map['Nombre'] ?? map['nombres'] ?? '',
      apellidos: map['Apellidos'] ?? map['apellidos'] ?? '',
      email: map['email'] ?? '',
      telefono: map['Telefono'] ?? map['telefono'] ?? '',
      role: map['Role'] ?? map['role'] ?? 'None',
      codigo: map['Codigo'] ?? map['codigo'] ?? '',
      codigoSupervisor:
          map['CodigoSupervisor'] ?? map['codigoSupervisor'] ?? '',
      fechaIngreso: map['createdAt'] != null
          ? (map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : map['createdAt'] as DateTime)
          : DateTime.now(),
      asignado: map['Asignado'] ?? map['asignado'] ?? false,
      imageUrl: map['imageUrl'],
    );
  }
}
