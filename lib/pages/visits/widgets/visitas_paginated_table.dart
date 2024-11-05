import 'package:admindashboard/models/visits.dart';
//import 'package:admindashboard/widgets/enhanced_search_bar.dart';
import 'package:admindashboard/widgets/search_bar.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ResponsiveVisitasTable extends StatefulWidget {
  final List<Visita> visitas;
  final Function(Visita) deleteVisit;
  final Function(BuildContext, dynamic, bool) showClientVisitFormDialog;
  final bool isLoading;

  const ResponsiveVisitasTable({
    super.key,
    required this.visitas,
    required this.deleteVisit,
    required this.showClientVisitFormDialog,
    required this.isLoading,
  });

  @override
  State<ResponsiveVisitasTable> createState() => _ResponsiveVisitasTableState();
}

class _ResponsiveVisitasTableState extends State<ResponsiveVisitasTable> {
  List<Visita> filteredVisitas = [];
  final TextEditingController _searchController = TextEditingController();
  bool isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    filteredVisitas = widget.visitas;
    _searchController.addListener(_filterVisitas);
  }

  @override
  void didUpdateWidget(ResponsiveVisitasTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visitas != widget.visitas) {
      _filterVisitas();
    }
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

  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isSmallScreen = constraints.maxWidth <= 430; // iPhone 14 Pro Max width

        return SizedBox(
          height: 200,
          child: Card(
            elevation: 4,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: EnhancedSearchBar(
                          controller: _searchController,
                          onClear: _clearSearch,
                          hintText: 'Buscar visitas...',
                          accentColor: Theme.of(context).primaryColor,
                          onSearchStateChanged: (isExpanded) {
                            setState(() {
                              isSearchExpanded = isExpanded;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: ElevatedButton(
                          onPressed: widget.isLoading
                              ? null
                              : () => widget.showClientVisitFormDialog(context, null, true),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: (isSmallScreen && isSearchExpanded)
                                ? const EdgeInsets.all(8)
                                : const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add_circle_outline, size: 20),
                              AnimatedSize(
                                duration: const Duration(milliseconds: 300),
                                child: (isSmallScreen && isSearchExpanded)
                                    ? const SizedBox.shrink()
                                    : const Row(
                                        children: [
                                          SizedBox(width: 8),
                                          Text('Nueva Visita'),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        ),
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
          ),
        );
      },
    );
  }

  Widget _buildTableContent(BuildContext context, BoxConstraints constraints) {
    if (widget.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando visitas...'),
          ],
        ),
      );
    }

    if (filteredVisitas.isEmpty) {
      return _buildEmptyState();
    }

    final isSmallScreen = constraints.maxWidth < 800;
    return isSmallScreen ? _buildListView() : _buildDataTable(context);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        _searchController.text.isEmpty
            ? "No hay visitas para mostrar"
            : "No se encontraron resultados para '${_searchController.text}'",
        style: const TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: filteredVisitas.length,
      itemBuilder: (context, index) {
        final item = filteredVisitas[index];
        return GestureDetector(
          onTap: () {
            widget.showClientVisitFormDialog(context, item, false);
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(
                item.nombreCliente,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${item.productoServicio} - ${DateFormat('dd/MM/yyyy').format(item.fecha)}',
                textAlign: TextAlign.center,
              ),
              trailing: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (String result) {
                  if (result == 'Editar') {
                    widget.showClientVisitFormDialog(context, item, true);
                  } else if (result == 'Eliminar') {
                    widget.deleteVisit(item);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
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
    final visitasDataSource = VisitasDataTableSource(
      filteredVisitas,
      widget.deleteVisit,
      widget.showClientVisitFormDialog,
      context,
    );

    return Theme(
      data: Theme.of(context).copyWith(
        cardColor: Colors.white,
        dividerColor: Colors.transparent,
        dataTableTheme: DataTableThemeData(
          headingTextStyle: TextStyle(
            color: Colors.blue[700],
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          dataTextStyle: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
      ),
      child: PaginatedDataTable2(
        header: null,
        columns: const [
          DataColumn2(
            label: Center(
              child: Text('NombreCliente', style: TextStyle(color: Colors.white)),
            ),
            size: ColumnSize.L,
          ),
          DataColumn2(
            label: Center(
              child: Text('Acciones', style: TextStyle(color: Colors.white)),
            ),
            size: ColumnSize.L,
          ),
          DataColumn2(
            label: Center(
              child: Text('Producto/Servicio', style: TextStyle(color: Colors.white)),
            ),
            size: ColumnSize.L,
          ),
          DataColumn2(
            label: Center(
              child: Text('Propósito Visita', style: TextStyle(color: Colors.white)),
            ),
            size: ColumnSize.L,
          ),
          DataColumn2(
            label: Center(
              child: Text('Fecha', style: TextStyle(color: Colors.white)),
            ),
            size: ColumnSize.L,
          ),
        ],
        source: visitasDataSource,
        rowsPerPage: 10,
        columnSpacing: 40,
        horizontalMargin: 20,
        showCheckboxColumn: false,
        headingRowHeight: 40,
        dataRowHeight: 60,
        headingRowColor: WidgetStateColor.resolveWith(
            (states) => Theme.of(context).primaryColor),
      ),
    );
  }
}

class VisitasDataTableSource extends DataTableSource {
  final List<Visita> visitas;
  final Function(Visita) deleteVisit;
  final Function(BuildContext, dynamic, bool) showClientVisitFormDialog;
  final BuildContext context;

  VisitasDataTableSource(
    this.visitas,
    this.deleteVisit,
    this.showClientVisitFormDialog,
    this.context,
  );

  @override
  DataRow? getRow(int index) {
    final visita = visitas[index];
    return DataRow2(
      color: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (index % 2 == 0) return Colors.grey.withOpacity(0.1);
          return null;
        },
      ),
      cells: [
        DataCell(Center(child: Text(visita.nombreCliente))),
        DataCell(Center(child: Text(visita.acciones))),
        DataCell(Center(child: Text(visita.productoServicio))),
        DataCell(Center(child: Text(visita.propVisita))),
        DataCell(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(DateFormat('dd/MM/yyyy').format(visita.fecha)),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Text('Editar'),
                    onTap: () => showClientVisitFormDialog(context, visita, true),
                  ),
                  PopupMenuItem(
                    child: const Text('Eliminar'),
                    onTap: () => deleteVisit(visita),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
      onTap: () => showClientVisitFormDialog(context, visita, false),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => visitas.length;

  @override
  int get selectedRowCount => 0;
}