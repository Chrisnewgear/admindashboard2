import 'package:admindashboard/models/clients.dart';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';

class UserTable extends StatefulWidget {
  final List<Clients> clients;
  final Function(Clients) onDelete;
  //final Function(Clients) onEdit;
  final Future<void> Function() onLoadUsers;

  const UserTable({
    super.key,
    required this.clients,
    required this.onDelete,
    //required this.onEdit,
    required this.onLoadUsers,
  });

  @override
  _UserTableState createState() => _UserTableState();
}

class _UserTableState extends State<UserTable> {
  List<Clients> _sortedClients = [];
  bool _sortAscending = true;
  int _sortColumnIndex = 0;

  @override
  void initState() {
    super.initState();
    _sortedClients = List.from(widget.clients);
  }

  void _sort<T>(Comparable<T> Function(Clients c) getField, int columnIndex, bool ascending) {
    _sortedClients.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending ? Comparable.compare(aValue, bValue) : Comparable.compare(bValue, aValue);
    });
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lista de Clientes',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                // ElevatedButton(
                //   onPressed: () => _showFormDialog(context, null),
                //   child: const Text('Nuevo Cliente'),
                // ),
              ],
            ),
            const SizedBox(height: 16),
            _sortedClients.isEmpty
                ? const SizedBox(
                    height: 400,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : SizedBox(
                    height: 400,
                    child: DataTable2(
                      columnSpacing: 12,
                      horizontalMargin: 12,
                      minWidth: 600,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
                      sortColumnIndex: _sortColumnIndex,
                      sortAscending: _sortAscending,
                      columns: [
                        DataColumn2(
                          label: const Text('Codigo', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                          size: ColumnSize.L,
                          onSort: (columnIndex, ascending) => _sort((c) => c.codigo, columnIndex, ascending),
                        ),
                        DataColumn2(
                          label: const Text('Nombres', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                          size: ColumnSize.L,
                          onSort: (columnIndex, ascending) => _sort((c) => c.nombres, columnIndex, ascending),
                        ),
                        DataColumn2(
                          label: const Text('Apellidos', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                          size: ColumnSize.L,
                          onSort: (columnIndex, ascending) => _sort((c) => c.apellidos, columnIndex, ascending),
                        ),
                        DataColumn2(
                          label: const Text('Email', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                          size: ColumnSize.L,
                          onSort: (columnIndex, ascending) => _sort((c) => c.email, columnIndex, ascending),
                        ),
                        DataColumn2(
                          label: const Text('Teléfono', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                          size: ColumnSize.L,
                          onSort: (columnIndex, ascending) => _sort((c) => c.telefono, columnIndex, ascending),
                        ),
                        DataColumn2(
                          label: const Text('Empresa', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                          size: ColumnSize.L,
                          onSort: (columnIndex, ascending) => _sort((c) => c.empresa, columnIndex, ascending),
                        ),
                        DataColumn2(
                          label: const Text('Direccion', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                          size: ColumnSize.L,
                          onSort: (columnIndex, ascending) => _sort((c) => c.direccion, columnIndex, ascending),
                        ),
                        DataColumn2(
                          label: const Text('Fecha Ingreso', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                          size: ColumnSize.L,
                          onSort: (columnIndex, ascending) => _sort((c) => c.fechaIngreso, columnIndex, ascending),
                        ),
                        const DataColumn2(
                          label: Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                          size: ColumnSize.S,
                        ),
                      ],
                      rows: _sortedClients
                          .map((client) => DataRow2(
                                cells: [
                                  DataCell(Text(client.codigo)),
                                  DataCell(Text(client.nombres)),
                                  DataCell(Text(client.apellidos)),
                                  DataCell(Text(client.email)),
                                  DataCell(Text(client.telefono)),
                                  DataCell(Text(client.empresa)),
                                  DataCell(Text(client.direccion)),
                                  DataCell(Text(DateFormat('dd/MM/yyyy').format(client.fechaIngreso))),
                                  DataCell(
                                    Row(
                                      children: [
                                        // IconButton(
                                        //   icon: const Icon(Icons.edit),
                                        //   onPressed: () => widget.onEdit(client),
                                        // ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () => widget.onDelete(client),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ))
                          .toList(),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}