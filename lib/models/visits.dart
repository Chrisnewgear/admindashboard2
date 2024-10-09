import 'package:cloud_firestore/cloud_firestore.dart';

class Visitas {
  final String id;
  final String acciones;
  final String codVendedor;
  final DateTime fecha;
  final String hora;
  final String notas;
  final String productoServicio;
  final String propVisita;

  Visitas({
    required this.id,
    required this.acciones,
    required this.codVendedor,
    required this.fecha,
    required this.hora,
    required this.notas,
    required this.productoServicio,
    required this.propVisita,
  });

  factory Visitas.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Visitas(
      id: doc.id,
      acciones: data['Acciones'] ?? '',
      codVendedor: data['CodVendedor'] ?? '',
      fecha: (data['Fecha'] as Timestamp).toDate(),
      hora: data['Hora'] ?? '',
      notas: data['Notas'] ?? '',
      productoServicio: data['ProductoServicio'] ?? '',
      propVisita: data['PropositoVisita'] ?? '',
    );
  }
}