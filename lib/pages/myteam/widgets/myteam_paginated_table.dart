
import 'package:admindashboard/widgets/search_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';

class ResponsiveMyTeamTable extends StatefulWidget {
  final bool isLoading;

  const ResponsiveMyTeamTable({super.key, required this.isLoading});

  @override
  State<ResponsiveMyTeamTable> createState() => _ResponsiveMyTeamTableState();
}

class _ResponsiveMyTeamTableState extends State<ResponsiveMyTeamTable> {
  List<Map<String, dynamic>> _tableData = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  int _rowsPerPage = 10;
  final List<int> _availableRowsPerPage = [5, 10, 20, 50];
  bool isSearchExpanded = false;
  List<Map<String, dynamic>> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _loadTableData();
    _searchController.addListener(_filterTableData);
  }

  Future<void> _loadTableData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        if (kDebugMode) {
          print('No user is logged in');
        }
        return;
      }

      var userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .get();

      Map<String, dynamic>? userData = userDoc.data();
      if (userData == null || userData['Role'] != 'Supervisor') {
        if (kDebugMode) {
          print('User is not a Supervisor or has no data');
        }
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
        filteredUsers = flattenedData; // Inicializar filteredUsers con los datos
        _isLoading = false;
      });
    } catch (e) {
      //print('Error loading table data: $e');
      //print('Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterTableData() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredUsers = _tableData.where((item) {
        return item['name'].toString().toLowerCase().contains(query) ||
            item['email'].toString().toLowerCase().contains(query) ||
            item['phone'].toString().toLowerCase().contains(query);
      }).toList();
    });
  }

  Widget _buildTableContent(BuildContext context, BoxConstraints constraints) {
    if (_isLoading) {
      return const TableShimmer();
    }

    if (filteredUsers.isEmpty) {
      return _buildEmptyState();
    }

    final isSmallScreen = constraints.maxWidth < 800;
    return isSmallScreen ? _buildListView() : _buildDataTable(context);
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
      ],
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      isSearchExpanded = false;
    });
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
        source: TableDataSource(
          filteredUsers,

          //widget.showClientVisitFormDialog,
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
    itemCount: filteredUsers.length,
    itemBuilder: (context, index) {
      final item = filteredUsers[index];
      // Acceder al nombre usando la sintaxis de Map y obtener la primera letra
      final firstLetter = item['name'].toString().isNotEmpty 
          ? item['name'].toString()[0].toUpperCase()
          : 'N/A';
      final backgroundColor = letterColors[firstLetter] ?? Colors.grey;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8),
          color: const Color(0xFFFFFFFF),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {},
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
                              item['name'] ?? 'N/A',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['email'] ?? 'N/A',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['phone'] ?? 'N/A',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
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
      const DataColumn2(
        label: Text('Avatar'),
        size: ColumnSize.S,
      ),
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

  // Add the letter colors map
  static const Map<String, Color> _letterColors = {
    'A': Colors.red,
    'B': Colors.orange,
    'C': Colors.lime,
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

  TableDataSource(this.tableData, this.context);

  // Updated method to use letterColors map
  Widget _buildUserAvatar(Map<String, dynamic> item) {
    String initials = item['name'] != null && item['name'].isNotEmpty
        ? item['name'][0].toUpperCase()
        : 'N/A';

    // Get color from map or use grey as fallback
    Color avatarColor = _letterColors[initials] ?? Colors.grey;

    return CircleAvatar(
      backgroundColor: avatarColor,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  DataRow? getRow(int index) {
    final item = tableData[index];
    return DataRow2(
      cells: [
        DataCell(_buildUserAvatar(item)), // Removed the hardcoded blue color
        DataCell(Text(item['name'] ?? 'N/A')),
        DataCell(Text(item['email'] ?? 'N/A')),
        DataCell(Text(item['phone'] ?? 'N/A')),
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
