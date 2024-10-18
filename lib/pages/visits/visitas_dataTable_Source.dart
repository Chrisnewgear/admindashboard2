import 'package:admindashboard/models/visits.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ResponsiveUserTable extends StatelessWidget {
  final List<Visitas> visitas;
  final Function(Visitas) deleteVisit;
  final Function(BuildContext, dynamic) showClientVisitFormDialog;

  const ResponsiveUserTable({
    super.key,
    required this.visitas,
    required this.deleteVisit,
    required this.showClientVisitFormDialog,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          elevation: 4,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          showClientVisitFormDialog(context, null),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Nueva Visita'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildTableContent(context, constraints),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTableContent(BuildContext context, BoxConstraints constraints) {
    if (visitas.isEmpty) {
      return _buildEmptyState();
    }

    final isSmallScreen = constraints.maxWidth < 600;

    return isSmallScreen ? _buildListView() : _buildDataTable(context);
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        "No hay visitas para mostrar",
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  // Widget _buildListView() {
  //   return ListView.builder(
  //     itemCount: visitas.length,
  //     itemBuilder: (context, index) {
  //       final visita = visitas[index];
  //       return Card(
  //         child: ListTile(
  //           title: const Text('Visitas'),
  //           subtitle: Text(visita.propVisita),
  //           trailing: IconButton(
  //             icon: const Icon(Icons.more_vert),
  //             onPressed: () {}
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: visitas.length,
      itemBuilder: (context, index) {
        final item = visitas[index];

        return Card(
          color: Colors.white,
          elevation: 4,
          child: ListTile(
            title: Text(item.acciones),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (String result) {
                if (result == 'Editar') {
                  showClientVisitFormDialog(context, item);
                } else if (result == 'Eliminar') {
                  deleteVisit(item);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'Editar',
                  child: Text('Editar'),
                ),
                const PopupMenuItem<String>(
                  value: 'Eliminar',
                  child: Text('Eliminar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDataTable(BuildContext context) {
    final visitasDataSource = VisitasDataTableSource(visitas, deleteVisit, showClientVisitFormDialog);

    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.grey[300],
        dataTableTheme: const DataTableThemeData(
          headingTextStyle: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
          dataTextStyle: TextStyle(color: Colors.black87),
        ),
      ),
      child: PaginatedDataTable(
        header: null,
        columns: const [
          DataColumn(label: Text('Acciones')),
          DataColumn(label: Text('Producto/Servicio')),
          DataColumn(label: Text('Propisito Visita')),
          DataColumn(label: Text('Fecha')),
          DataColumn(label: Text('')),
        ],
        source: visitasDataSource,
        rowsPerPage: 10,
        columnSpacing: 100,
        horizontalMargin: 40,
        showCheckboxColumn: false,
      ),
    );
  }
}

class VisitasDataTableSource extends DataTableSource {
  final List<Visitas> visitas;
  final Function(Visitas) deleteVisit;
  final Function(BuildContext, dynamic) showClientVisitFormDialog;

  VisitasDataTableSource(
    this.visitas,
    this.deleteVisit,
    this.showClientVisitFormDialog,
  );

  @override
  DataRow getRow(int index) {
    final visita = visitas[index];
    return DataRow(
      cells: [
        DataCell(Text(visita.acciones)),
        DataCell(Text(visita.productoServicio)),
        DataCell(Text(visita.propVisita)),
        DataCell(Center(child: Text((DateFormat('dd/MM/yyyy').format(visita.fecha))))),
        DataCell(PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            PopupMenuItem(
                child: const Text('Editar'),
                onTap: () => showClientVisitFormDialog(context, visita)),
            PopupMenuItem(
              child: const Text('Eliminar'),
              onTap: () => deleteVisit(visita),
            ),
          ],
        )),
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
