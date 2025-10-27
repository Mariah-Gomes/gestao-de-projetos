import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const _cTeal   = Color(0xFF0F6C73);
const _cOrange = Color(0xFFF0A94A);

class DashboardCharts extends StatelessWidget {
  const DashboardCharts({super.key, required this.docs});
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;

  @override
  Widget build(BuildContext context) {
    // agrega por semana (1..5) do mês
    final List<Map<String, double>> byWeek =
        List.generate(5, (_) => {'in': 0.0, 'out': 0.0});

    // série do saldo diário
    final Map<int, double> byDay = {};

    for (final d in docs) {
      final m = d.data();
      final date = (m['date'] as Timestamp).toDate();

      final double amount = (m['amount'] is num)
          ? (m['amount'] as num).toDouble()
          : (num.tryParse('${m['amount']}') ?? 0).toDouble();

      final bool isIncome = (m['type'] == 'income');

      // semana do mês (0..4)
      final int day = date.day;
      final int w = ((day - 1) ~/ 7).clamp(0, 4);

      if (isIncome) {
        byWeek[w]['in'] = (byWeek[w]['in']! + amount);
      } else {
        byWeek[w]['out'] = (byWeek[w]['out']! + amount);
      }

      byDay[day] = (byDay[day] ?? 0) + (isIncome ? amount : -amount);
    }

    // saldo acumulado
    final sortedDays = byDay.keys.toList()..sort();
    double running = 0;
    final List<FlSpot> lineSpots = [];
    if (sortedDays.isEmpty) {
      for (var i = 1; i <= 5; i++) {
        lineSpots.add(FlSpot(i.toDouble(), 0));
      }
    } else {
      for (final d in sortedDays) {
        running += byDay[d]!;
        lineSpots.add(FlSpot(d.toDouble(), running));
      }
    }

    final money = NumberFormat.simpleCurrency(locale: 'pt_BR');

    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        const titleH = 22.0;
        const gapH = 8.0;
        final chartH = ((h - (titleH * 2) - (gapH * 3)).clamp(120.0, h)) / 2;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SectionTitle('Entradas x Saídas por semana'),
              const SizedBox(height: gapH),
              SizedBox(
                height: chartH,
                child: BarChart(
                  BarChartData(
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final label = switch (groupIndex) {
                            0 => '1ª', 1 => '2ª', 2 => '3ª', 3 => '4ª', _ => '5ª',
                          };
                          final t = (rod.color == _cTeal) ? 'Entrada' : 'Saída';
                          return BarTooltipItem(
                            '$label semana\n$t: ${money.format(rod.toY)}',
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          );
                        },
                      ),
                    ),
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, meta) {
                            final i = v.toInt();
                            final label = switch (i) {
                              0 => '1ª', 1 => '2ª', 2 => '3ª', 3 => '4ª', _ => '5ª',
                            };
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(label, style: const TextStyle(fontSize: 12, color: _cTeal)),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: List.generate(5, (i) {
                      final double entrada = byWeek[i]['in']!;
                      final double saida   = byWeek[i]['out']!;
                      return BarChartGroupData(
                        x: i,
                        barsSpace: 6,
                        barRods: [
                          BarChartRodData(toY: entrada, color: _cTeal,   width: 14, borderRadius: BorderRadius.circular(4)),
                          BarChartRodData(toY: saida,   color: _cOrange, width: 14, borderRadius: BorderRadius.circular(4)),
                        ],
                      );
                    }),
                  ),
                ),
              ),

              const SizedBox(height: gapH * 2),

              const _SectionTitle('Saldo acumulado no mês'),
              const SizedBox(height: gapH),
              SizedBox(
                height: chartH,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(
                      show: true,
                      border: const Border.fromBorderSide(BorderSide(color: Color(0x22000000))),
                    ),
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: lineSpots.isEmpty ? 1 : null,
                          getTitlesWidget: (v, meta) => Text(
                            v.toInt().toString(),
                            style: const TextStyle(fontSize: 10, color: _cTeal),
                          ),
                        ),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: lineSpots,
                        isCurved: true,
                        barWidth: 3,
                        color: _cTeal,
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: _cTeal,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
