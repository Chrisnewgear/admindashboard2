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
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: () => showClientVisitFormDialog(context, null),
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
                Expanded(child: _buildTableContent(context, constraints)),
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

  Widget _buildListView() {
    return ListView.builder(
      itemCount: visitas.length,
      itemBuilder: (context, index) {
        final item = visitas[index];
        return Card(
          color: Colors.white,
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text(item.acciones, textAlign: TextAlign.center),
            subtitle: Text('${item.productoServicio} - ${DateFormat('dd/MM/yyyy').format(item.fecha)}',
                textAlign: TextAlign.center),
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
        cardColor: Colors.white,
        dividerColor: Colors.grey[300],
        dataTableTheme: DataTableThemeData(
          headingTextStyle: TextStyle(
            color: Colors.blue[700],
            fontWeight: FontWeight.bold,
          ),
          dataTextStyle: const TextStyle(color: Colors.black87),
        ),
      ),
      child: PaginatedDataTable(
        header: null,
        columns: const [
          DataColumn(label: Center(child: Text('Acciones'))),
          DataColumn(label: Center(child: Text('Producto/Servicio'))),
          DataColumn(label: Center(child: Text('Propósito Visita'))),
          DataColumn(label: Center(child: Text('Fecha'))),
          DataColumn(label: Text('')), // Última columna sin centrar
        ],
        source: visitasDataSource,
        rowsPerPage: 5,
        columnSpacing: 40,
        horizontalMargin: 20,
        showCheckboxColumn: false,
        headingRowHeight: 40,
        dataRowMaxHeight: 60,
        dataRowMinHeight: 48,
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
      color: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (index % 2 == 0) return Colors.grey.withOpacity(0.1);
          return null;
        },
      ),
      cells: [
        DataCell(Center(child: Text(visita.acciones))),
        DataCell(Center(child: Text(visita.productoServicio))),
        DataCell(Center(child: Text(visita.propVisita))),
        DataCell(Center(child: Text(DateFormat('dd/MM/yyyy').format(visita.fecha)))),
        DataCell(PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('Editar'),
              onTap: () => showClientVisitFormDialog(context, visita),
            ),
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