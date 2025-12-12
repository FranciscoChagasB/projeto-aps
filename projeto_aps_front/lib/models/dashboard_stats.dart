class DashboardStats {
  final Map<String, int> statusDistribution;
  final List<DailyCount> history;

  DashboardStats({required this.statusDistribution, required this.history});

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    // Converte o Map<String, dynamic> do JSON para Map<String, int>
    final dist = Map<String, int>.from(json['statusDistribution'] ?? {});
    
    final hist = (json['last7DaysHistory'] as List? ?? [])
        .map((e) => DailyCount.fromJson(e))
        .toList();

    return DashboardStats(statusDistribution: dist, history: hist);
  }
}

class DailyCount {
  final DateTime date;
  final int count;

  DailyCount({required this.date, required this.count});

  factory DailyCount.fromJson(Map<String, dynamic> json) {
    return DailyCount(
      date: DateTime.parse(json['date']),
      count: json['count'],
    );
  }
}