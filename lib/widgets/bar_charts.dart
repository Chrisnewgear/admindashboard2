import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SimpleBarChart extends StatelessWidget {
  const SimpleBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                    margin: const EdgeInsets.all(24),
                    child: BarChart(
                      BarChartData(
                        barGroups: [
                          BarChartGroupData(
                            x: 1,
                            barRods: [BarChartRodData(toY: 15)],
                          ),
                          BarChartGroupData(
                            x: 2,
                            barRods: [BarChartRodData(toY: 10)],
                          ),
                          BarChartGroupData(
                            x: 3,
                            barRods: [BarChartRodData(toY: 7)],
                          ),
                          BarChartGroupData(
                            x: 4,
                            barRods: [BarChartRodData(toY: 2)],
                          ),
                        ],
                        alignment: BarChartAlignment.spaceEvenly,
                        titlesData: const FlTitlesData(
                            leftTitles: AxisTitles(
                                axisNameWidget: Text('Revenues'),
                                sideTitles: SideTitles(
                                  reservedSize: 44, showTitles: true
                                )
                            )
                        ),
                      ),
                    )
                  )
                )
              )
            );
  }
}
