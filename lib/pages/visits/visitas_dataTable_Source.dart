// ignore: file_names
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:admindashboard/models/visits.dart';


class VisitasDataTableSource extends DataTableSource {
  final List<Visitas> visitas;
  final Function(Visitas) onDeleteVisit;  // Callback para eliminar la visita

  VisitasDataTableSource(this.visitas, this.onDeleteVisit);

  @override
  DataRow getRow(int index) {
    final visita = visitas[index];
    return DataRow(
      cells: [
        DataCell(Center(child: Text(visita.acciones))),
        DataCell(Center(child: Text(visita.productoServicio))),
        DataCell(Center(child: Text(visita.propVisita))),
        DataCell(Center(child: Text(DateFormat('dd/MM/yyyy').format(visita.fecha)))),
        DataCell(
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'Eliminar') {
                    onDeleteVisit(visita);  // Usar el callback aquí
                  } else if (value == 'Deshabilitar') {
                    print('Aqui se va a deshabilitar');
                  }
                },
                itemBuilder: (BuildContext context) => [
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
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => visitas.length;

  @override
  int get selectedRowCount => 0;
}
