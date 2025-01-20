import 'package:admindashboard/Shimmers/listView_shimmer.dart';
import 'package:admindashboard/Shimmers/table_shimmer.dart';
import 'package:admindashboard/models/visits.dart';
//import 'package:admindashboard/widgets/enhanced_search_bar.dart';
import 'package:admindashboard/widgets/search_bar.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ResponsiveVisitasTable extends StatefulWidget {
  final List<Visita> visitas;
  final Function(Visita) deleteVisit;
  final Function(BuildContext, dynamic, bool) showVisitFormDialog;
  final bool isLoading;
  final Future<bool> Function() hasRole;

  const ResponsiveVisitasTable({
    super.key,
    required this.visitas,
    required this.deleteVisit,
    required this.showVisitFormDialog,
    required this.isLoading,
    required this.hasRole,
  });

  @override
  State<ResponsiveVisitasTable> createState() => _ResponsiveVisitasTableState();
}

class _ResponsiveVisitasTableState extends State<ResponsiveVisitasTable> {
  List<Visita> filteredVisitas = [];
  final TextEditingController _searchController = TextEditingController();
  bool isSearchExpanded = false;
  bool hasRol = false;
  String _sortColumn = 'nombreCliente';
  bool _sortAscending = true;
  int _rowsPerPage = 10;

  final List<int> _availableRowsPerPage = [5, 10, 20, 50];

  @override
  void initState() {
    super.initState();
    filteredVisitas = widget.visitas;
    _searchController.addListener(_filterVisitas);
    _checkRole();
    _sortVisitas();
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

  void _sortVisitas() {
    filteredVisitas.sort((a, b) {
      dynamic valueA;
      dynamic valueB;

      switch (_sortColumn) {
        case 'nombreCliente':
          valueA = a.nombreCliente;
          valueB = b.nombreCliente;
          break;
        case 'productoServicio':
          valueA = a.productoServicio;
          valueB = b.productoServicio;
          break;
        case 'fechaVisita':
          valueA = a.fecha;
          valueB = b.fecha;
          break;
        case 'propVisita':
          valueA = a.propVisita;
          valueB = b.propVisita;
          break;
        default:
          valueA = a.nombreCliente;
          valueB = b.nombreCliente;
      }

      final comparision = _sortAscending
          ? Comparable.compare(valueA, valueB)
          : Comparable.compare(valueB, valueA);

      return comparision;
    });
  }

  void _showNoRoleDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Acceso Denegado"),
          content: const Text(
              "No tiene asignado un rol, por lo que no podrá crear, ver o editar las visitas, comuníquese con su supervisor."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Aceptar"),
            ),
          ],
        );
      },
    );
  }

  void _filterVisitas() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredVisitas = widget.visitas.where((visita) {
        return visita.nombreCliente.toLowerCase().contains(query) ||
            visita.productoServicio.toLowerCase().contains(query) ||
            visita.propVisita.toLowerCase().contains(query) ||
            visita.acciones.toLowerCase().contains(query) ||
            DateFormat('dd/MM/yyyy')
                .format(visita.fecha)
                .toLowerCase()
                .contains(query);
      }).toList();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      isSearchExpanded = false;
    });
  }

  @override
  void didUpdateWidget(ResponsiveVisitasTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visitas != widget.visitas) {
      _filterVisitas();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            hintText: 'Buscar Visita...',
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
                : () => widget.showVisitFormDialog(context, null, true),
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
                const Icon(Icons.add_circle_outline, size: 20),
                if (!isSearchExpanded) const SizedBox(width: 8),
                if (!isSearchExpanded) const Text('Nueva Visita'),
              ],
            ),
          ),
        ),
      ],
    );
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

  Widget _buildTableContent(BuildContext context, BoxConstraints constraints) {
    final isSmallScreen = constraints.maxWidth < 800;

    if (widget.isLoading) {
      return isSmallScreen
        ? const ListViewShimmer(itemCount: 7)
        : const TableShimmer(itemCount: 7);
    }

    if (filteredVisitas.isEmpty) {
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
      itemCount: filteredVisitas.length,
      itemBuilder: (context, index) {
        final item = filteredVisitas[index];
        final firstLetter = item.nombreCliente[0].toUpperCase();
        final backgroundColor = letterColors[firstLetter];

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Card(
            elevation: 3, // Slightly higher elevation for a more defined shadow
            margin: const EdgeInsets.symmetric(vertical: 8),
            color: const Color(0xFFFFFFFF), // Light pastel beige color
            child: InkWell(
              borderRadius:
                  BorderRadius.circular(12), // Slightly more rounded corners
              onTap: () => widget.showVisitFormDialog(context, item, false),
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
                                item.nombreCliente,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.propVisita,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.productoServicio,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat('dd/MM/yyyy').format(item.fecha),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
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

  Widget _buildPopupMenu(Visita visita) {
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
          onTap: () => widget.showVisitFormDialog(context, visita, true),
        ),
        PopupMenuItem(
          child: const Row(
            children: [
              Icon(Icons.delete, size: 20, color: Colors.red),
              SizedBox(width: 8),
              Text('Eliminar', style: TextStyle(color: Colors.red)),
            ],
          ),
          //onTap: () => widget.deleteVisit(visita),
          onTap: () => _showDeleteConfirmationDialog(visita),
        ),
      ],
    );
  }

  void _showDeleteConfirmationDialog(Visita visita) {
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
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¿Está seguro que desea eliminar esta visita?',
                  style: TextStyle(fontSize: 16),
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
                widget.deleteVisit(visita);
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
        source: VisitasDataTableSource(
          filteredVisitas,
          widget.deleteVisit,
          widget.showVisitFormDialog,
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
      _buildColumn('Acciones', 'acciones', ColumnSize.L),
      _buildColumn('Producto/Servicio', 'productoservicio', ColumnSize.M),
      _buildColumn('Motivo', 'motivo', ColumnSize.M),
      DataColumn2(
        label: const Text('Fecha',
            textAlign: TextAlign.center), // Center-aligned label
        size: ColumnSize.S,
        numeric: false,
        onSort: (columnIndex, ascending) {
          setState(() {
            _sortColumn = 'fechaIngreso';
            _sortAscending = ascending;
            _sortVisitas();
          });
        },
      ),
      const DataColumn2(
        label: Text('', textAlign: TextAlign.center),
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
          _sortVisitas();
        });
      },
    );
  }
}

class VisitasDataTableSource extends DataTableSource {
  final List<Visita> visitas;
  final Function(Visita) deleteVisit;
  final Function(BuildContext, dynamic, bool) showVisitFormDialog;
  final BuildContext context;

  VisitasDataTableSource(
    this.visitas,
    this.deleteVisit,
    this.showVisitFormDialog,
    this.context,
  );

  @override
  DataRow? getRow(int index) {
    final visita = visitas[index];
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
        DataCell(Text(visita.nombreCliente)),
        DataCell(Text(visita.acciones)),
        DataCell(Text(visita.productoServicio)),
        DataCell(Text(visita.propVisita)),
        DataCell(_buildDateCell(visita.fecha)),
        DataCell(_buildActionsCell(visita)),
      ],
      onTap: () => showVisitFormDialog(context, visita, false),
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

  Widget _buildActionsCell(Visita visita) {
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
          onPressed: () => showVisitFormDialog(context, visita, true),
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
          onPressed: () => _showDeleteConfirmationDialog(visita),
        ),
      ],
    );
  }

  void _showDeleteConfirmationDialog(Visita visita) {
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
              const Text(
                '¿Está seguro que desea eliminar esta visita?',
                style: TextStyle(fontSize: 16),
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
                deleteVisit(visita);
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
  int get rowCount => visitas.length;

  @override
  int get selectedRowCount => 0;
}
