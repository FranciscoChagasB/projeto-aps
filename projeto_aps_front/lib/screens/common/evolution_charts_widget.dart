import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart';

class EvolutionChartsWidget extends StatefulWidget {
  final int criancaId;
  const EvolutionChartsWidget({super.key, required this.criancaId});

  @override
  State<EvolutionChartsWidget> createState() => _EvolutionChartsWidgetState();
}

class _EvolutionChartsWidgetState extends State<EvolutionChartsWidget> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<DashboardProvider>(context, listen: false)
        .fetchEvolution(widget.criancaId));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());
        if (provider.stats == null) return const SizedBox();

        final stats = provider.stats!;
        
        // Dados para o Gráfico de Pizza
        final concluido = stats.statusDistribution['CONCLUIDO'] ?? 0;
        final dificuldade = stats.statusDistribution['CONCLUIDO_COM_DIFICULDADE'] ?? 0;
        final naoConcluido = stats.statusDistribution['NAO_CONCLUIDO'] ?? 0;
        final total = concluido + dificuldade + naoConcluido;

        return Column(
          children: [
            // GRÁFICO DE PIZZA
            const Text("Distribuição de Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            if (total == 0)
              const Padding(padding: EdgeInsets.all(20), child: Text("Sem dados suficientes."))
            else
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(value: concluido.toDouble(), color: Colors.green, title: '$concluido', radius: 50),
                      PieChartSectionData(value: dificuldade.toDouble(), color: Colors.orange, title: '$dificuldade', radius: 50),
                      PieChartSectionData(value: naoConcluido.toDouble(), color: Colors.red, title: '$naoConcluido', radius: 50),
                    ],
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            
            // GRÁFICO DE BARRAS (Histórico)
            const Text("Atividades Concluídas (Últimos 7 dias)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 1, reservedSize: 28)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < stats.history.length) {
                            return Text(DateFormat('dd/MM').format(stats.history[value.toInt()].date), style: const TextStyle(fontSize: 10));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  barGroups: stats.history.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [BarChartRodData(toY: entry.value.count.toDouble(), color: Colors.blue, width: 16)],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}