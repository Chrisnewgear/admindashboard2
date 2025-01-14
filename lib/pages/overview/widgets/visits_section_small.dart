import 'package:admindashboard/pages/overview/widgets/visits_shimmer_small.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:admindashboard/widgets/bar_charts.dart';
import 'package:admindashboard/constants/style.dart';

class VisitsSectionSmall extends StatefulWidget {
  const VisitsSectionSmall({super.key});

  @override
  State<VisitsSectionSmall> createState() => _VisitsSectionSmallState();
}

class _VisitsSectionSmallState extends State<VisitsSectionSmall> {
  late Future<Map<String, int>> _visitsCounts;

  @override
  void initState() {
    super.initState();
    _visitsCounts = _fetchVisitsCounts();
  }

  Future<Map<String, int>> _fetchVisitsCounts() async {
    final visitsRef = FirebaseFirestore.instance.collection('Visits');
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfYear = DateTime(now.year, 1, 1);

    try {
      final todayVisits = await visitsRef
          .where('Fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(today))
          .count()
          .get();

      final weekVisits = await visitsRef
          .where('Fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
          .count()
          .get();

      final monthVisits = await visitsRef
          .where('Fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .count()
          .get();

      final yearVisits = await visitsRef
          .where('Fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfYear))
          .count()
          .get();

      return {
        'today': todayVisits.count ?? 0,
        'week': weekVisits.count ?? 0,
        'month': monthVisits.count ?? 0,
        'year': yearVisits.count ?? 0,
      };
    } catch (e) {
      debugPrint('Error fetching visits counts: $e');
      throw Exception('Error al obtener conteos de visitas');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 6),
            color: lightGrey.withOpacity(.1),
            blurRadius: 12,
          ),
        ],
        border: Border.all(color: lightGrey, width: .5),
      ),
      child: FutureBuilder<Map<String, int>>(
        future: _visitsCounts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            //return const Center(child: CircularProgressIndicator());
            return const VisitsShimmerSmall();
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final counts = snapshot.data!;

          return Column(
            children: [
              const Text(
                'Resumen de Visitas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  _buildCard(
                    'Visitas Hoy',
                    counts['today']?.toString() ?? '0',
                    Colors.blue,
                    Icons.today,
                  ),
                  _buildCard(
                    'Visitas Semana',
                    counts['week']?.toString() ?? '0',
                    Colors.green,
                    Icons.calendar_view_week,
                  ),
                  _buildCard(
                    'Visitas Mes',
                    counts['month']?.toString() ?? '0',
                    Colors.orange,
                    Icons.calendar_month,
                  ),
                  _buildCard(
                    'Visitas Año',
                    counts['year']?.toString() ?? '0',
                    Colors.purple,
                    Icons.calendar_today,
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const SizedBox(
                height: 200,
                child: SimpleBarChart(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCard(String title, String count, Color color, IconData icon) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                count,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
