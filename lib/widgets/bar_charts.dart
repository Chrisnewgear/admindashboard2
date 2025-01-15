import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SimpleBarChart extends StatefulWidget {
  const SimpleBarChart({super.key});

  @override
  State<SimpleBarChart> createState() => _SimpleBarChartState();
}

class _SimpleBarChartState extends State<SimpleBarChart> {
  late Future<List<BarChartGroupData>> _visitsFuture;
  static const _queryTimeout = Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    _visitsFuture = _fetchVisitsData();
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<List<BarChartGroupData>> _fetchVisitsData() async {
    final visitsCollection = FirebaseFirestore.instance.collection('Visits');
    List<BarChartGroupData> barGroups = [];

    try {
      final querySnapshot = await visitsCollection
          .get(const GetOptions(source: Source.server))
          .timeout(_queryTimeout);

      if (!mounted) return [];

      DateTime now = DateTime.now();
      DateTime threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
      Map<int, int> monthlyVisits = {};

      for (var doc in querySnapshot.docs) {
        DateTime visitDate = (doc['Fecha'] as Timestamp).toDate();
        if (visitDate.isAfter(threeMonthsAgo)) {
          int monthKey = visitDate.month;
          monthlyVisits[monthKey] = (monthlyVisits[monthKey] ?? 0) + 1;
        }
      }

      for (int i = 2; i >= 0; i--) {
        int monthIndex = (now.month - i - 1) % 12;
        if (monthIndex < 0) monthIndex += 12;

        barGroups.add(
          BarChartGroupData(
            x: 2 - i,
            barRods: [
              BarChartRodData(
                toY: (monthlyVisits[monthIndex + 1] ?? 0).toDouble(),
                width: 25,
                color: Colors.blue.shade300,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(6)),
              )
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint("Error al obtener datos de visitas: $e");
      _showErrorSnackBar('Error al cargar datos de visitas');
      return [];
    }

    return barGroups;
  }

  // @override
  // Widget build(BuildContext context) {
  //   final size = MediaQuery.of(context).size;

  //   return Container(
  //     height: size.height * 0.6,
  //     width: size.width * 0.8,
  //     padding: const EdgeInsets.all(16),
  //     child: FutureBuilder<List<BarChartGroupData>>(
  //       future: _visitsFuture,
  //       builder: (context, snapshot) {
  //         // if (snapshot.connectionState == ConnectionState.waiting) {
  //         //   return const Center(child: CircularProgressIndicator());
  //         // }

  //         if (snapshot.hasError) {
  //           _showErrorSnackBar('Error: ${snapshot.error}');
  //           return const Center(
  //             child: Icon(Icons.error_outline, color: Colors.red, size: 60),
  //           );
  //         }

  //         if (!snapshot.hasData || snapshot.data!.isEmpty) {
  //           return const Center(
  //             child: Text(
  //               'No ha tenido visitas en los últimos 3 meses',
  //               style: TextStyle(fontSize: 16),
  //             ),
  //           );
  //         }

  //         return BarChart(
  //           BarChartData(
  //             barGroups: snapshot.data!,
  //             alignment: BarChartAlignment.spaceEvenly,
  //             maxY: 50,
  //             barTouchData: BarTouchData(enabled: true),
  //             gridData: const FlGridData(
  //               show: true,
  //               drawVerticalLine: false,
  //               horizontalInterval: 10,
  //             ),
  //             borderData: FlBorderData(
  //               show: true,
  //               border: Border.all(color: Colors.grey.shade300),
  //             ),
  //             titlesData: FlTitlesData(
  //               show: true,
  //               bottomTitles: AxisTitles(
  //                 sideTitles: SideTitles(
  //                   showTitles: true,
  //                   reservedSize: 30,
  //                   getTitlesWidget: (double value, TitleMeta meta) {
  //                     final List<String> months = [
  //                       'Ene',
  //                       'Feb',
  //                       'Mar',
  //                       'Abr',
  //                       'May',
  //                       'Jun',
  //                       'Jul',
  //                       'Ago',
  //                       'Sep',
  //                       'Oct',
  //                       'Nov',
  //                       'Dic'
  //                     ];
  //                     final currentMonth = DateTime.now().month;
  //                     final monthIndex =
  //                         (currentMonth - 3 + value.toInt()) % 12;
  //                     return Text(months[monthIndex]);
  //                   },
  //                 ),
  //                 axisNameWidget: const Padding(
  //                   padding: EdgeInsets.only(top: 1.0),
  //                   child: Text('Últimos 3 meses'),
  //                 ),
  //               ),
  //               leftTitles: const AxisTitles(
  //                 sideTitles: SideTitles(
  //                   showTitles: true,
  //                   reservedSize: 44,
  //                   interval: 10,
  //                 ),
  //                 axisNameWidget: Padding(
  //                   padding: EdgeInsets.only(bottom: 1.0),
  //                   child: Text('Visitas'),
  //                 ),
  //               ),
  //               topTitles:
  //                   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
  //               rightTitles:
  //                   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.6,
      width: size.width * 0.8,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FutureBuilder<List<BarChartGroupData>>(
        future: _visitsFuture,
        builder: (context, snapshot) {
          // ...existing loading and error states...
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            _showErrorSnackBar('Error: ${snapshot.error}');
            return const Center(
              child: Icon(Icons.error_outline, color: Colors.red, size: 60),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No ha tenido visitas en los últimos 3 meses',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return BarChart(
            BarChartData(
              barGroups: snapshot.data!,
              alignment: BarChartAlignment.spaceEvenly,
              maxY: 50,
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      final List<String> months = [
                        'Ene',
                        'Feb',
                        'Mar',
                        'Abr',
                        'May',
                        'Jun',
                        'Jul',
                        'Ago',
                        'Sep',
                        'Oct',
                        'Nov',
                        'Dic'
                      ];
                      final currentMonth = DateTime.now().month;
                      final monthIndex =
                          (currentMonth - 3 + value.toInt()) % 12;
                      return Text(months[monthIndex]);
                    },
                  ),
                  axisNameWidget: const Padding(
                    padding: EdgeInsets.only(top: 1.0),
                    child: Text(
                      'Últimos 3 meses',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 44,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      );
                    },
                  ),
                  axisNameWidget: const Padding(
                    padding: EdgeInsets.only(bottom: 1.0),
                    child: Text(
                      'Visitas',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 10,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  );
                },
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey.shade300),
              ),
              backgroundColor: Colors.white,
            ),
            swapAnimationDuration: const Duration(milliseconds: 500),
            swapAnimationCurve: Curves.easeInOutCubic,
          );
        },
      ),
    );
  }
}
