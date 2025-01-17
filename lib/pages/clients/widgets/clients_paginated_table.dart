import 'package:admindashboard/Shimmers/listView_shimmer.dart';
import 'package:admindashboard/Shimmers/table_shimmer.dart';
import 'package:admindashboard/models/clients.dart';
// import 'package:admindashboard/pages/roles/Widgets/listView_shimmer.dart';
// import 'package:admindashboard/pages/roles/Widgets/table_shimmer.dart';
//import 'package:admindashboard/pages/roles/Widgets/table_shimmer.dart';
import 'package:admindashboard/widgets/search_bar.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//import 'package:shimmer/shimmer.dart';


class ResponsiveClientsTable extends StatefulWidget {
  final List<Cliente> clientes;
  final Function(Cliente) deleteClient;
  final Function(BuildContext, dynamic, bool) showClientVisitFormDialog;
  final bool isLoading;
  final Future<bool> Function() hasRole;

  const ResponsiveClientsTable({
    super.key,
    required this.clientes,
    required this.deleteClient,
    required this.showClientVisitFormDialog,
    required this.isLoading,
    required this.hasRole,
  });

  @override
  State<ResponsiveClientsTable> createState() => _ResponsiveClientsTableState();
}

class _ResponsiveClientsTableState extends State<ResponsiveClientsTable> {
  List<Cliente> filteredClientes = [];
  final TextEditingController _searchController = TextEditingController();
  bool isSearchExpanded = false;
  bool hasRol = false;
  String _sortColumn = 'nombres';
  bool _sortAscending = true;
  int _rowsPerPage = 10;
  final List<int> _availableRowsPerPage = [5, 10, 20, 50];

  @override
  void initState() {
    super.initState();
    filteredClientes = widget.clientes;
    _searchController.addListener(_filterClientes);
    _checkRole();
    _sortClientes();
  }

  Future<void> _checkRole() async {
    final role = await widget.hasRole();
    setState(() {
      hasRol = role;
    });

    if (!hasRol) {
      _showNoRoleDialog();
    }
  }

  void _sortClientes() {
    filteredClientes.sort((a, b) {
      dynamic valueA;
      dynamic valueB;

      switch (_sortColumn) {
        case 'nombres':
          valueA = a.nombre;
          valueB = b.nombre;
          break;
        case 'apellidos':
          valueA = a.apellido;
          valueB = b.apellido;
          break;
        case 'empresa':
          valueA = a.empresa;
          valueB = b.empresa;
          break;
        case 'telefono':
          valueA = a.telefono;
          valueB = b.telefono;
          break;
        case 'fechaIngreso':
          valueA = a.fechaIngreso;
          valueB = b.fechaIngreso;
          break;
        default:
          valueA = a.nombre;
          valueB = b.nombre;
      }

      final comparison = _sortAscending
          ? Comparable.compare(valueA, valueB)
          : Comparable.compare(valueB, valueA);
      return comparison;
    });
  }

  void _showNoRoleDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.amber),
              SizedBox(width: 8),
              Text('Acceso Denegado'),
            ],
          ),
          content: const Text(
              "No tiene asignado un rol, por lo que no podrá crear, ver o editar sus clientes, comuníquese con su supervisor."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  void _filterClientes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredClientes = widget.clientes.where((cliente) {
        return cliente.nombre.toLowerCase().contains(query) ||
            cliente.apellido.toLowerCase().contains(query) ||
            cliente.telefono.toLowerCase().contains(query) ||
            cliente.email.toLowerCase().contains(query) ||
            cliente.empresa.toLowerCase().contains(query) ||
            DateFormat('dd/MM/yyyy')
                .format(cliente.fechaIngreso)
                .toLowerCase()
                .contains(query);
      }).toList();
      _sortClientes();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      isSearchExpanded = false;
    });
  }

  @override
  void didUpdateWidget(ResponsiveClientsTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.clientes != widget.clientes) {
      setState(() {
        filteredClientes = widget.clientes;
        _sortClientes();
      });
    }
  }

  Widget _buildRowsPerPageDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _rowsPerPage,
          items: _availableRowsPerPage.map((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text('$value filas'),
            );
          }).toList(),
          onChanged: (int? newValue) {
            if (newValue != null) {
              setState(() {
                _rowsPerPage = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isSmallScreen = constraints.maxWidth <= 430;

        return Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context, isSmallScreen),
                const SizedBox(height: 16),
                Expanded(child: _buildTableContent(context, constraints)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isSmallScreen) {
    return Row(
      children: [
        Expanded(
          child: EnhancedSearchBar(
            controller: _searchController,
            onClear: _clearSearch,
            hintText: 'Buscar Cliente...',
            accentColor: Theme.of(context).primaryColor,
            onSearchStateChanged: (isExpanded) {
              setState(() {
                isSearchExpanded = isExpanded;
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        if (!isSmallScreen)
          _buildRowsPerPageDropdown(), // Show only on larger screens
        const SizedBox(width: 16),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: isSearchExpanded
              ? const EdgeInsets.all(
                  0) // Shrink button size when search is expanded
              : const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12), // Normal size
          child: ElevatedButton(
            onPressed: (widget.isLoading || !hasRol)
                ? null
                : () => widget.showClientVisitFormDialog(context, null, true),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: isSearchExpanded
                  ? const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12) // Normal padding when collapsed
                  : const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12), // Expand padding when expanded
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_circle_outline, size: 11),
                if (!isSearchExpanded) const SizedBox(width: 8),
                if (!isSearchExpanded) const Text('Nuevo Cliente'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget _buildTableContent(BuildContext context, BoxConstraints constraints) {
  //   if (widget.isLoading) {
  //     return Center(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           const CircularProgressIndicator(),
  //           const SizedBox(height: 16),
  //           Text(
  //             'Cargando clientes...',
  //             style: TextStyle(
  //               color: Colors.grey[600],
  //               fontSize: 16,
  //             ),
  //           )
  //         ],
  //       ),
  //     );
  //   }

  //   if (filteredClientes.isEmpty) {
  //     return _buildEmptyState();
  //   }

  //   final isSmallScreen = constraints.maxWidth < 800;
  //   return isSmallScreen ? _buildListView() : _buildDataTable(context);
  // }

  Widget _buildTableContent(BuildContext context, BoxConstraints constraints) {
    final isSmallScreen = constraints.maxWidth < 800;

    if (widget.isLoading) {
      return isSmallScreen
        ? const ListViewShimmer(itemCount: 7)
        : const TableShimmer(itemCount: 7);
    }

    if (filteredClientes.isEmpty) {
      return _buildEmptyState();
    }

    return isSmallScreen ? _buildListView() : _buildDataTable(context);
  }



  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              top: 16,
              left: 16,
              right: 16,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person_search,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  _searchController.text.isEmpty
                      ? "No hay visitas para mostrar"
                      : "No se encontraron resultados para '${_searchController.text}'",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListView() {
    final Map<String, Color> letterColors = {
      'A': Colors.red,
      'B': Colors.orange,
      'C': Colors.yellow,
      'D': Colors.green,
      'E': Colors.blue,
      'F': Colors.purple,
      'G': Colors.pink,
      'H': Colors.brown,
      'I': Colors.grey,
      'J': Colors.blueGrey,
      'K': Colors.deepPurple,
      'L': Colors.deepOrange,
      'M': Colors.deepPurpleAccent,
      'N': Colors.indigo,
      'O': Colors.indigoAccent,
      'P': Colors.pinkAccent,
      'Q': Colors.purpleAccent,
      'R': Colors.redAccent,
      'S': Colors.teal,
      'T': Colors.tealAccent,
      'U': Colors.greenAccent,
      'V': Colors.lightGreen,
      'W': Colors.lightGreenAccent,
      'X': Colors.amber,
      'Y': Colors.amberAccent,
      'Z': Colors.purple,
    };

    return ListView.builder(
      itemCount: filteredClientes.length,
      itemBuilder: (context, index) {
        final item = filteredClientes[index];
        final firstLetter = item.nombre[0].toUpperCase();
        final backgroundColor = letterColors[firstLetter] ??
            Colors.grey; // Default color if not found

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Card(
            elevation: 3, // Slightly higher elevation for a more defined shadow
            margin: const EdgeInsets.symmetric(vertical: 8),
            color: const Color(0xFFFFFFFF), // Light pastel beige color
            child: InkWell(
              borderRadius:
                  BorderRadius.circular(12), // Slightly more rounded corners
              onTap: () =>
                  widget.showClientVisitFormDialog(context, item, false),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: backgroundColor,
                          child: Text(
                            firstLetter,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${item.nombre} ${item.apellido}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.email,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.empresa,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.telefono,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildPopupMenu(item),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPopupMenu(Cliente cliente) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      itemBuilder: (context) => [
        PopupMenuItem(
          child: const Row(
            children: [
              Icon(Icons.edit, size: 20),
              SizedBox(width: 8),
              Text('Editar'),
            ],
          ),
          onTap: () => widget.showClientVisitFormDialog(context, cliente, true),
        ),
        PopupMenuItem(
          child: const Row(
            children: [
              Icon(Icons.delete, size: 20, color: Colors.red),
              SizedBox(width: 8),
              Text('Eliminar', style: TextStyle(color: Colors.red)),
            ],
          ),
          onTap: () => _showDeleteConfirmationDialog(cliente),
        ),
      ],
    );
  }

  void _showDeleteConfirmationDialog(Cliente cliente) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.amber[700],
              ),
              const SizedBox(width: 8),
              const Text('Eliminación'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Está seguro que desea eliminar al cliente ${cliente.nombre} ${cliente.apellido}?',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Text(
                'Esta acción no se puede deshacer.',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Eliminar'),
              onPressed: () {
                widget.deleteClient(cliente);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDataTable(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        cardColor: Colors.white,
        dividerColor: Colors.grey[200],
        dataTableTheme: DataTableThemeData(
          headingTextStyle: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          dataTextStyle: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
      ),
      child: PaginatedDataTable2(
        columns: _buildColumns(),
        source: ClientesDataTableSource(
          filteredClientes,
          widget.deleteClient,
          widget.showClientVisitFormDialog,
          context,
        ),
        rowsPerPage: _rowsPerPage,
        columnSpacing: 24,
        horizontalMargin: 24,
        showCheckboxColumn: false,
        headingRowHeight: 48,
        dataRowHeight: 64,
        headingRowColor: WidgetStateProperty.resolveWith(
          (states) => Colors.grey[50]!,
        ),
        onSelectAll: null,
        empty: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning, size: 40, color: Colors.amber[700]),
                const SizedBox(height: 16),
                const Text(
                  'No se encontraron registros',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<DataColumn2> _buildColumns() {
    return [
      _buildColumn('Nombre', 'nombres', ColumnSize.L),
      _buildColumn('Apellidos', 'apellidos', ColumnSize.L),
      _buildColumn('Empresa', 'empresa', ColumnSize.M),
      _buildColumn('Teléfono', 'telefono', ColumnSize.M),
      _buildColumn('Fecha Ingreso', 'fechaIngreso', ColumnSize.M),
      const DataColumn2(
        label: Text('Acciones', textAlign: TextAlign.center),
        size: ColumnSize.S,
        numeric: false,
        fixedWidth: 100,
      ),
    ];
  }

  DataColumn2 _buildColumn(String label, String columnId, ColumnSize size) {
    return DataColumn2(
      label: Text(label, textAlign: TextAlign.center),
      size: size,
      numeric: false,
      onSort: (columnIndex, ascending) {
        setState(() {
          _sortColumn = columnId;
          _sortAscending = ascending;
          _sortClientes();
        });
      },
    );
  }
}

class ClientesDataTableSource extends DataTableSource {
  final List<Cliente> clientes;
  final Function(Cliente) deleteCliente;
  final Function(BuildContext, dynamic, bool) showClienteFormDialog;
  final BuildContext context;

  ClientesDataTableSource(
    this.clientes,
    this.deleteCliente,
    this.showClienteFormDialog,
    this.context,
  );

  @override
  DataRow? getRow(int index) {
    final cliente = clientes[index];
    return DataRow2(
      color: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return Theme.of(context).colorScheme.primary.withOpacity(0.08);
          }
          if (states.contains(WidgetState.hovered)) {
            return Colors.grey.withOpacity(0.05);
          }
          if (index % 2 == 0) return Colors.grey.withOpacity(0.02);
          return null;
        },
      ),
      cells: [
        DataCell(Text(cliente.nombre)),
        DataCell(Text(cliente.apellido)),
        DataCell(Text(cliente.email)),
        DataCell(Text(cliente.telefono)),
        DataCell(_buildDateCell(cliente.fechaIngreso)),
        DataCell(_buildActionsCell(cliente)),
      ],
      onTap: () => showClienteFormDialog(context, cliente, false),
    );
  }

  Widget _buildDateCell(DateTime date) {
    return Text(
      DateFormat('dd/MM/yy').format(date), // Shortened date format
      style: TextStyle(
        color: Colors.grey[800],
        fontSize: 13, // Slightly smaller font
      ),
    );
  }

  Widget _buildActionsCell(Cliente cliente) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center, // Center the icons
      children: [
        IconButton(
          constraints: const BoxConstraints(), // Remove minimum constraints
          padding: const EdgeInsets.all(8), // Reduce padding
          icon: Icon(
            Icons.edit_outlined,
            color: Colors.blue[700],
            size: 20,
          ),
          tooltip: 'Editar',
          onPressed: () => showClienteFormDialog(context, cliente, true),
        ),
        IconButton(
          constraints: const BoxConstraints(), // Remove minimum constraints
          padding: const EdgeInsets.all(8), // Reduce padding
          icon: const Icon(
            Icons.delete_outline,
            color: Colors.red,
            size: 20,
          ),
          tooltip: 'Eliminar',
          onPressed: () => _showDeleteConfirmationDialog(cliente),
        ),
      ],
    );
  }

  void _showDeleteConfirmationDialog(Cliente cliente) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.amber[700],
              ),
              const SizedBox(width: 8),
              const Text('Confirmar Eliminación'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Está seguro que desea eliminar al usuario ${cliente.nombre} ${cliente.apellido}?',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Text(
                'Esta acción no se puede deshacer.',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Eliminar'),
              onPressed: () {
                deleteCliente(cliente);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => clientes.length;

  @override
  int get selectedRowCount => 0;
}

// class TableShimmer extends StatelessWidget {
//   const TableShimmer({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemCount: 5,
//       itemBuilder: (context, index) {
//         return Container(
//           margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(8),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.1),
//                 spreadRadius: 1,
//                 blurRadius: 3,
//                 offset: const Offset(0, 1),
//               ),
//             ],
//           ),
//           child: Row(
//             children: [
//               _buildShimmerBox(40, 40, true),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildShimmerBox(120, 16),
//                     const SizedBox(height: 8),
//                     _buildShimmerBox(80, 12),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 16),
//               _buildShimmerBox(60, 24),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildShimmerBox(double width, double height,
//       [bool isCircle = false]) {
//     return Container(
//       width: width,
//       height: height,
//       decoration: BoxDecoration(
//         color: Colors.grey[200],
//         borderRadius: BorderRadius.circular(isCircle ? height / 2 : 4),
//       ),
//     );
//   }
// }

// class TableShimmer extends StatelessWidget {
//   final int itemCount;
//   final double verticalSpacing;
//   final double horizontalPadding;

//   const TableShimmer({
//     super.key,
//     this.itemCount = 5,
//     this.verticalSpacing = 8.0,
//     this.horizontalPadding = 16.0,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 1,
//             blurRadius: 3,
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header with search and add button
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 _buildShimmerBox(150, 40), // Title
//                 Row(
//                   children: [
//                     _buildShimmerBox(200, 40, isSearchBar: true), // Search bar
//                     const SizedBox(width: 16),
//                     _buildShimmerBox(100, 40), // Add button
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Row(
//               children: [
//                 // Column headers
//                 Expanded(flex: 2, child: _buildShimmerBox(100, 20)),
//                 const SizedBox(width: 16),
//                 Expanded(flex: 2, child: _buildShimmerBox(100, 20)),
//                 const SizedBox(width: 16),
//                 Expanded(child: _buildShimmerBox(100, 20)),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),
//           // Data rows
//           Expanded(
//             child: ListView.separated(
//               itemCount: itemCount,
//               separatorBuilder: (context, index) => const Divider(height: 1),
//               itemBuilder: (context, index) {
//                 return Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         flex: 2,
//                         child: Row(
//                           children: [
//                             _buildShimmerBox(40, 40, isCircle: true),
//                             const SizedBox(width: 12),
//                             Expanded(child: _buildShimmerBox(100, 20)),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         flex: 2,
//                         child: _buildShimmerBox(150, 20),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             _buildShimmerBox(32, 32),
//                             const SizedBox(width: 8),
//                             _buildShimmerBox(32, 32),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildShimmerBox(double width, double height, {
//     bool isCircle = false,
//     bool isSearchBar = false,
//   }) {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey[300]!,
//       highlightColor: Colors.grey[100]!,
//       child: Container(
//         width: width,
//         height: height,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(
//             isCircle ? 50 : isSearchBar ? 30 : 4,
//           ),
//         ),
//       ),
//     );
//   }
// }


// class TableShimmer extends StatelessWidget {
//   final int itemCount;
//   final double verticalSpacing;
//   final double horizontalPadding;

//   const TableShimmer({
//     super.key,
//     this.itemCount = 5,
//     this.verticalSpacing = 8.0,
//     this.horizontalPadding = 16.0,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 1,
//             blurRadius: 3,
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header with search and add button
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 _buildShimmerBox(150, 40), // Title
//                 Row(
//                   children: [
//                     _buildShimmerBox(200, 40, isSearchBar: true), // Search bar
//                     const SizedBox(width: 16),
//                     _buildShimmerBox(100, 40), // Add button
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Row(
//               children: [
//                 // Column headers
//                 Expanded(flex: 2, child: _buildShimmerBox(100, 20)),
//                 const SizedBox(width: 16),
//                 Expanded(flex: 2, child: _buildShimmerBox(100, 20)),
//                 const SizedBox(width: 16),
//                 Expanded(child: _buildShimmerBox(100, 20)),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),
//           // Data rows
//           Expanded(
//             child: ListView.separated(
//               itemCount: itemCount,
//               separatorBuilder: (context, index) => const Divider(height: 1),
//               itemBuilder: (context, index) {
//                 return Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         flex: 2,
//                         child: Row(
//                           children: [
//                             _buildShimmerBox(40, 40, isCircle: true),
//                             const SizedBox(width: 12),
//                             Expanded(child: _buildShimmerBox(100, 20)),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         flex: 2,
//                         child: _buildShimmerBox(150, 20),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             _buildShimmerBox(32, 32),
//                             const SizedBox(width: 8),
//                             _buildShimmerBox(32, 32),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildShimmerBox(double width, double height, {
//     bool isCircle = false,
//     bool isSearchBar = false,
//   }) {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey[300]!,
//       highlightColor: Colors.grey[100]!,
//       child: Container(
//         width: width,
//         height: height,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(
//             isCircle ? 50 : isSearchBar ? 30 : 4,
//           ),
//         ),
//       ),
//     );
//   }
// }
