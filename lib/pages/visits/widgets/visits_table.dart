import 'package:flutter/material.dart';

class ResponsiveUserTable extends StatelessWidget {
  final List<dynamic> visitas;
  final Function(dynamic) deleteVisit;
  final Function(dynamic, dynamic) showClientVisitFormDialog;

  const ResponsiveUserTable({
    super.key,
    required this.visitas,
    required this.deleteVisit, required this.showClientVisitFormDialog,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          elevation: 0,
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
                      child: const Text('Agendar Visita'),
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

    if (isSmallScreen) {
      return _buildListView();
    } else {
      return _buildDataTable(context);
    }
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
        final visita = visitas[index];
        return Card(
          child: ListTile(
            title: Text('${visita.nombres} ${visita.apellidos}'),
            subtitle: Text(visita.email),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // Implementar menú de acciones
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildDataTable(BuildContext context) {
    final visitasDataSource = VisitasDataTableSource(visitas, deleteVisit);

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
          DataColumn(label: Text('Nombres')),
          DataColumn(label: Text('Apellidos')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Teléfono')),
          DataColumn(label: Text('Empresa')),
          DataColumn(label: Text('Fecha Ingreso')),
          DataColumn(label: Text('')),
        ],
        source: visitasDataSource,
        rowsPerPage: 10,
        columnSpacing: 24,
        horizontalMargin: 0,
        showCheckboxColumn: false,
      ),
    );
  }
}

class VisitasDataTableSource extends DataTableSource {
  final List<dynamic> visitas;
  final Function(dynamic) deleteVisit;

  VisitasDataTableSource(this.visitas, this.deleteVisit);

  @override
  DataRow getRow(int index) {
    final visita = visitas[index];
    return DataRow(
      cells: [
        DataCell(Text(visita.nombres)),
        DataCell(Text(visita.apellidos)),
        DataCell(Text(visita.email)),
        DataCell(Text(visita.telefono)),
        DataCell(Text(visita.empresa)),
        DataCell(Text(visita.fechaIngreso)),
        DataCell(PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('Editar'),
              onTap: () {
                // Implementar edición
              },
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