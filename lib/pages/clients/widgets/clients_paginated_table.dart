import 'package:admindashboard/models/clients.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ResponsiveClientsTable extends StatelessWidget {
  final List<Clients> clientes;
  final Function(Clients) deleteClient;
  final Function(BuildContext, dynamic) showClientVisitFormDialog;
  final bool isLoading;

  const ResponsiveClientsTable({
    super.key,
    required this.clientes,
    required this.deleteClient,
    required this.showClientVisitFormDialog,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: 200,
          child: Card(
            elevation: 4,
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        onPressed: isLoading ? null : () => showClientVisitFormDialog(context, null),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Agregar Cliente'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(child: _buildTableContent(context, constraints)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTableContent(BuildContext context, BoxConstraints constraints) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando clientes...')
          ],
        ),
      );
    }

    if (clientes.isEmpty) {
      return _buildEmptyState();
    }

    final isSmallScreen = constraints.maxWidth < 800;

    return isSmallScreen ? _buildListView() : _buildDataTable(context);
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        "No hay clientes para mostrar",
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: clientes.length,
      itemBuilder: (context, index) {
        final item = clientes[index];
        return GestureDetector(
          onTap: () {
            // Al hacer tap en la tarjeta, mostrar el cuadro de diálogo para editar
            showClientVisitFormDialog(context, item);
          },
          child: Card(
            color: Colors.white,
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              title: Text(
                '${item.nombres} ${item.apellidos}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${item.telefono} - ${DateFormat('dd/MM/yyyy').format(item.fechaIngreso)}',
                textAlign: TextAlign.center,
              ),
              trailing: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (String result) {
                  if (result == 'Editar') {
                    showClientVisitFormDialog(
                        context, item); // Cuadro de diálogo para editar
                  } else if (result == 'Eliminar') {
                    deleteClient(item); // Lógica para eliminar
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
          ),
        );
      },
    );
  }

  Widget _buildDataTable(BuildContext context) {
    final clientesDataSource = ClientesDataTableSource(
        clientes, deleteClient, showClientVisitFormDialog, context);

    return Theme(
      data: Theme.of(context).copyWith(
        cardColor: Colors.white,
        dividerColor: Colors.grey[300],
        dataTableTheme: DataTableThemeData(
          headingTextStyle: TextStyle(
            color: Colors.blue[700], // Color del texto del encabezado
            fontWeight: FontWeight.bold, // Texto en negrita
            fontSize: 16, // Tamaño de letra más grande
          ),
          dataTextStyle: const TextStyle(
            color: Colors.black87, // Color del texto de las celdas
            fontSize: 14, // Tamaño de texto de las celdas
          ),
        ),
      ),
      child: PaginatedDataTable2(
        header: null,
        columns: const [
          DataColumn2(
            label: Center(
              child: Text(
                'Nombres',
                style: TextStyle(color: Colors.white), // Texto blanco
              ),
            ),
            size: ColumnSize.L,
            numeric:
                false, // Para evitar que las columnas numéricas se alineen a la derecha
          ),
          DataColumn2(
            label: Center(
              child: Text(
                'Apellidos',
                style: TextStyle(color: Colors.white), // Texto blanco
              ),
            ),
            size: ColumnSize.L,
          ),
          DataColumn2(
            label: Center(
              child: Text(
                'Empresa',
                style: TextStyle(color: Colors.white), // Texto blanco
              ),
            ),
            size: ColumnSize.L,
          ),
          DataColumn2(
            label: Center(
              child: Text(
                'Teléfono',
                style: TextStyle(color: Colors.white), // Texto blanco
              ),
            ),
            size: ColumnSize.L,
          ),
          DataColumn2(
            label: Center(
              child: Text(
                'Fecha Ingreso',
                style: TextStyle(color: Colors.white), // Texto blanco
              ),
            ),
            size: ColumnSize.L,
          ),
          // DataColumn2(
          //   label: Text(''),
          //   size: ColumnSize.S,
          // ),
        ],
        source: clientesDataSource,
        rowsPerPage: 10,
        columnSpacing: 40,
        horizontalMargin: 20,
        showCheckboxColumn: false,
        headingRowHeight: 40,
        dataRowHeight: 60,
        headingRowColor: WidgetStateColor.resolveWith(
            (states) => Colors.blue[900]!), // Fondo azul para el encabezado
      ),
    );
  }
}

class ClientesDataTableSource extends DataTableSource {
  final List<Clients> clientes;
  final Function(Clients) deleteClient;
  final Function(BuildContext, dynamic) showClientVisitFormDialog;
  final BuildContext context;

  ClientesDataTableSource(
    this.clientes,
    this.deleteClient,
    this.showClientVisitFormDialog,
    this.context,
  );

  @override
  DataRow? getRow(int index) {
    final cliente = clientes[index];
    return DataRow2(
      color: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (index % 2 == 0) return Colors.grey.withOpacity(0.1);
          return null;
        },
      ),
      cells: [
        // DataCell(Center(
        //   child: GestureDetector(
        //     onTap: () => showClientVisitFormDialog(context, cliente),
        //     child: Text(cliente.nombres),
        //   ),
        // )),
        DataCell(Center(child: Text(cliente.nombres))),
        DataCell(Center(child: Text(cliente.apellidos))),
        DataCell(Center(child: Text(cliente.empresa))),
        DataCell(Center(child: Text(cliente.telefono))),
        DataCell(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(DateFormat('dd/MM/yyyy').format(cliente.fechaIngreso)),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Text('Editar'),
                    onTap: () => showClientVisitFormDialog(context, cliente),
                  ),
                  PopupMenuItem(
                    child: const Text('Eliminar'),
                    onTap: () => deleteClient(cliente),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
      onTap: () => showClientVisitFormDialog(context, cliente),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => clientes.length;

  @override
  int get selectedRowCount => 0;
}
