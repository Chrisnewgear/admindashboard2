import 'package:admindashboard/models/usuarios.dart';
import 'package:admindashboard/widgets/search_bar.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ResponsiveRolesTable extends StatefulWidget {
  final List<Usuario> usuarios;
  final Function(Usuario) deleteUsuario;
  final Function(BuildContext, dynamic) showUsuarioFormDialog;
  final bool isLoading;

  const ResponsiveRolesTable({
    super.key,
    required this.usuarios,
    required this.deleteUsuario,
    required this.showUsuarioFormDialog,
    required this.isLoading,
  });

  @override
  State<ResponsiveRolesTable> createState() => _ResponsiveRolesTableState();
}

class _ResponsiveRolesTableState extends State<ResponsiveRolesTable> {
  List<Usuario> filteredUsuarios = [];
  final TextEditingController _searchController = TextEditingController();
  bool isSearchExpanded = false;
  String _sortColumn = 'nombres';
  bool _sortAscending = true;
  int _rowsPerPage = 10;

  final List<int> _availableRowsPerPage = [5, 10, 20, 50];

  @override
  void initState() {
    super.initState();
    filteredUsuarios = widget.usuarios;
    _searchController.addListener(_filterUsuarios);
    _sortUsuarios();
  }

  @override
  void didUpdateWidget(ResponsiveRolesTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.usuarios != widget.usuarios) {
      _filterUsuarios();
      _sortUsuarios();
    }
  }

  void _sortUsuarios() {
    filteredUsuarios.sort((a, b) {
      dynamic valueA;
      dynamic valueB;

      switch (_sortColumn) {
        case 'nombres':
          valueA = a.nombres;
          valueB = b.nombres;
          break;
        case 'apellidos':
          valueA = a.apellidos;
          valueB = b.apellidos;
          break;
        case 'email':
          valueA = a.email;
          valueB = b.email;
          break;
        case 'role':
          valueA = a.role;
          valueB = b.role;
          break;
        case 'fechaIngreso':
          valueA = a.fechaIngreso;
          valueB = b.fechaIngreso;
          break;
        default:
          valueA = a.nombres;
          valueB = b.nombres;
      }

      final comparison = _sortAscending
          ? Comparable.compare(valueA, valueB)
          : Comparable.compare(valueB, valueA);
      return comparison;
    });
  }

  void _filterUsuarios() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredUsuarios = widget.usuarios.where((usuario) {
        return usuario.nombres.toLowerCase().contains(query) ||
            usuario.apellidos.toLowerCase().contains(query) ||
            usuario.email.toLowerCase().contains(query) ||
            usuario.telefono.toLowerCase().contains(query) ||
            usuario.role.toLowerCase().contains(query) ||
            usuario.codigo.toLowerCase().contains(query) ||
            DateFormat('dd/MM/yyyy')
                .format(usuario.fechaIngreso)
                .toLowerCase()
                .contains(query);
      }).toList();
      _sortUsuarios();
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
        return Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                const SizedBox(height: 16),
                Expanded(child: _buildTableContent(context, constraints)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: EnhancedSearchBar(
            controller: _searchController,
            onClear: _clearSearch,
            hintText: 'Buscar Usuario...',
            accentColor: Theme.of(context).primaryColor,
            onSearchStateChanged: (isExpanded) {
              setState(() {
                isSearchExpanded = isExpanded;
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        _buildRowsPerPageDropdown(),
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
    if (widget.isLoading) {
      return _buildLoadingState();
    }

    if (filteredUsuarios.isEmpty) {
      return _buildEmptyState();
    }

    final isSmallScreen = constraints.maxWidth < 800;
    return isSmallScreen ? _buildListView() : _buildDataTable(context);
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Cargando usuarios...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty
                ? "No hay usuarios para mostrar"
                : "No se encontraron resultados para '${_searchController.text}'",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: filteredUsuarios.length,
      itemBuilder: (context, index) {
        final item = filteredUsuarios[index];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Card(
            elevation: 1,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => widget.showUsuarioFormDialog(context, item),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: _getRoleColor(item.role),
                          child: Text(
                            item.nombres[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${item.nombres} ${item.apellidos}',
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
                            ],
                          ),
                        ),
                        _buildPopupMenu(item),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildRoleChip(item.role),
                        Text(
                          DateFormat('dd/MM/yyyy').format(item.fechaIngreso),
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleChip(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getRoleColor(role).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getRoleColor(role).withOpacity(0.3),
        ),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: _getRoleColor(role),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPopupMenu(Usuario usuario) {
    return Flexible(
      child: PopupMenuButton<String>(
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
            onTap: () => widget.showUsuarioFormDialog(context, usuario),
          ),
          PopupMenuItem(
            child: const Row(
              children: [
                Icon(Icons.delete, size: 20, color: Colors.red),
                SizedBox(width: 8),
                Text('Eliminar', style: TextStyle(color: Colors.red)),
              ],
            ),
            onTap: () => widget.deleteUsuario(usuario),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(BuildContext context) {
  return Theme(
    data: Theme.of(context).copyWith(
      cardColor: Colors.white, // Cambia el color de fondo de la tabla a blanco
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
      source: UsuariosDataTableSource(
        filteredUsuarios,
        widget.deleteUsuario,
        widget.showUsuarioFormDialog,
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
      _buildColumn('Email', 'email', ColumnSize.M),
      _buildColumn('Teléfono', 'telefono', ColumnSize.M),
      _buildColumn('Role', 'role', ColumnSize.M),
      DataColumn2(
        label: const Text('Fecha',
            textAlign: TextAlign.center), // Center-aligned label
        size: ColumnSize.S,
        numeric: false,
        onSort: (columnIndex, ascending) {
          setState(() {
            _sortColumn = 'fechaIngreso';
            _sortAscending = ascending;
            _sortUsuarios();
          });
        },
      ),
      const DataColumn2(
        label: Text('Acciones',
            textAlign: TextAlign.center), // Center-aligned label
        size: ColumnSize.S,
        numeric: false,
        fixedWidth: 100, // Fixed width for actions column
      ),
    ];
  }

  DataColumn2 _buildColumn(String label, String columnId, ColumnSize size) {
    return DataColumn2(
      label: Text(label, textAlign: TextAlign.center), // Center-aligned label
      size: size,
      numeric: false,
      onSort: (columnIndex, ascending) {
        setState(() {
          _sortColumn = columnId;
          _sortAscending = ascending;
          _sortUsuarios();
        });
      },
    );
  }
}

class UsuariosDataTableSource extends DataTableSource {
  final List<Usuario> usuarios;
  final Function(Usuario) deleteUsuario;
  final Function(BuildContext, dynamic) showUsuarioFormDialog;
  final BuildContext context;

  UsuariosDataTableSource(
    this.usuarios,
    this.deleteUsuario,
    this.showUsuarioFormDialog,
    this.context,
  );

  @override
  DataRow? getRow(int index) {
    final usuario = usuarios[index];
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
        DataCell(Text(usuario.nombres)),
        DataCell(Text(usuario.apellidos)),
        DataCell(Text(usuario.email)),
        DataCell(Text(usuario.telefono)),
        DataCell(_buildRoleCell(usuario.role)),
        DataCell(_buildDateCell(usuario.fechaIngreso)),
        DataCell(_buildActionsCell(usuario)),
      ],
      onTap: () => showUsuarioFormDialog(context, usuario),
    );
  }

  Widget _buildRoleCell(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getRoleColor(role).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getRoleColor(role).withOpacity(0.3),
        ),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: _getRoleColor(role),
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
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

  Widget _buildActionsCell(Usuario usuario) {
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
          onPressed: () => showUsuarioFormDialog(context, usuario),
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
          onPressed: () => _showDeleteConfirmationDialog(usuario),
        ),
      ],
    );
  }

  void _showDeleteConfirmationDialog(Usuario usuario) {
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
                '¿Está seguro que desea eliminar al usuario ${usuario.nombres} ${usuario.apellidos}?',
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
                deleteUsuario(usuario);
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
  int get rowCount => usuarios.length;

  @override
  int get selectedRowCount => 0;
}

Color _getRoleColor(String role) {
  switch (role.toLowerCase()) {
    case 'admin':
      return const Color(0xFF1E293B); // Slate 800
    case 'supervisor':
      return const Color(0xFF059669); // Emerald 600
    case 'vendedor':
      return const Color(0xFF0284C7); // Sky 600
    default:
      return const Color(0xFF64748B); // Slate 500
  }
}

class TableShimmer extends StatelessWidget {
  const TableShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildShimmerBox(40, 40, true),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmerBox(120, 16),
                    const SizedBox(height: 8),
                    _buildShimmerBox(80, 12),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _buildShimmerBox(60, 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmerBox(double width, double height,
      [bool isCircle = false]) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(isCircle ? height / 2 : 4),
      ),
    );
  }
}
