import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';

class ResponsiveMyTeamTable extends StatefulWidget {
  const ResponsiveMyTeamTable({super.key});

  @override
  State<ResponsiveMyTeamTable> createState() => _ResponsiveMyTeamTableState();
}

class _ResponsiveMyTeamTableState extends State<ResponsiveMyTeamTable> {
  List<Map<String, dynamic>> _tableData = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  int _rowsPerPage = 10;
  int _totalRows = 0;

  @override
  void initState() {
    super.initState();
    _loadTableData();
    _searchController.addListener(_filterTableData);
  }

  Future<void> _loadTableData() async {
    try {
      // Obtener el usuario actualmente logueado
      var currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('No user is logged in');
        return;
      }

      // Obtener el documento del usuario actualmente logueado
      var userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .get();

      Map<String, dynamic>? userData = userDoc.data();
      if (userData == null || userData['Role'] != 'Supervisor') {
        print('User is not a Supervisor or has no data');
        return;
      }

      List<Map<String, dynamic>> flattenedData = [];
      String supervisorName = userData['NombreSupervisor'] ?? '';

      if (userData.containsKey('MyTeam') && userData['MyTeam'] is List) {
        for (var member in userData['MyTeam']) {
          if (member is Map<String, dynamic>) {
            Map<String, dynamic> memberData = {
              'name': '${member['Nombre'] ?? ''} ${member['Apellidos'] ?? ''}',
              'email': member['email'] ?? '',
              'phone': member['Telefono'] ?? '',
              'nombreSupervisor': supervisorName,
            };
            flattenedData.add(memberData);
          }
        }
      }

      setState(() {
        _tableData = flattenedData;
        _totalRows = _tableData.length;
        _isLoading = false;
        _filterTableData();
      });
    } catch (e, stackTrace) {
      print('Error loading table data: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterTableData() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _tableData = _tableData.where((item) {
        return item['name'].toLowerCase().contains(query) ||
            item['email'].toLowerCase().contains(query) ||
            item['phone'].toLowerCase().contains(query);
      }).toList();
    });
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

  Widget _buildHeader(BuildContext context, bool isSmallScreen) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _searchController.clear(),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableContent(BuildContext context, BoxConstraints constraints) {
    if (_isLoading) {
      return const TableShimmer();
    }

    if (_tableData.isEmpty) {
      return _buildEmptyState();
    }

    final int startIndex = (_currentPage - 1) * _rowsPerPage;
    final int endIndex = startIndex + _rowsPerPage;
    final List<Map<String, dynamic>> paginatedData = _tableData.sublist(
        startIndex,
        endIndex < _tableData.length ? endIndex : _tableData.length);

    return PaginatedDataTable2(
      columns: _buildColumns(),
      source: TableDataSource(paginatedData, context),
      rowsPerPage: _rowsPerPage,
      availableRowsPerPage: const [5, 10, 20, 50],
      onPageChanged: (page) {
        setState(() {
          _currentPage = page;
        });
      },
      onRowsPerPageChanged: (rowsPerPage) {
        setState(() {
          _rowsPerPage = rowsPerPage!;
          _currentPage = 1;
        });
      },
      columnSpacing: 24,
      horizontalMargin: 24,
      showCheckboxColumn: false,
      empty: _buildEmptyState(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.table_view,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty
                ? "No hay datos para mostrar"
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

  List<DataColumn2> _buildColumns() {
    return [
      DataColumn2(
        label: const Text('Nombre'),
        size: ColumnSize.L,
        onSort: (columnIndex, ascending) {
          setState(() {
            _sortTable('name', ascending);
          });
        },
      ),
      DataColumn2(
        label: const Text('Email'),
        size: ColumnSize.L,
        onSort: (columnIndex, ascending) {
          setState(() {
            _sortTable('email', ascending);
          });
        },
      ),
      DataColumn2(
        label: const Text('Teléfono'),
        size: ColumnSize.L,
        onSort: (columnIndex, ascending) {
          setState(() {
            _sortTable('phone', ascending);
          });
        },
      ),
      // DataColumn2(
      //   label: const Text('Rol'),
      //   size: ColumnSize.L,
      //   onSort: (columnIndex, ascending) {
      //     setState(() {
      //       _sortTable('role', ascending);
      //     });
      //   },
      // ),
      DataColumn2(
        label: const Text('Nombre Supervisor'),
        size: ColumnSize.L,
        onSort: (columnIndex, ascending) {
          setState(() {
            _sortTable('nombreSupervisor', ascending);
          });
        },
      ),
    ];
  }

  void _sortTable(String columnName, bool ascending) {
    _tableData.sort((a, b) {
      final valueA = a[columnName];
      final valueB = b[columnName];
      return ascending
          ? Comparable.compare(valueA, valueB)
          : Comparable.compare(valueB, valueA);
    });
    setState(() {});
  }
}

class TableDataSource extends DataTableSource {
  final List<Map<String, dynamic>> tableData;
  final BuildContext context;

  TableDataSource(this.tableData, this.context);

  @override
  DataRow? getRow(int index) {
    final item = tableData[index];
    return DataRow2(
      cells: [
        DataCell(Text(item['name'] ?? 'N/A')),
        DataCell(Text(item['email'] ?? 'N/A')),
        DataCell(Text(item['phone'] ?? 'N/A')),
        //DataCell(Text(item['role'] ?? 'N/A')),
        DataCell(Text(item['nombreSupervisor'] ?? 'N/A')),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => tableData.length;

  @override
  int get selectedRowCount => 0;
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