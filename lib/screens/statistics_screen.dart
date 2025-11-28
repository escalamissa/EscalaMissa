import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:escala_missa/services/statistics_service.dart';

class StatisticsScreen extends StatefulWidget {
  static const routeName = '/admin/statistics';
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final StatisticsService _statisticsService = StatisticsService();
  Map<String, int> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStatistics();
  }

  Future<void> _fetchStatistics() async {
    if(!mounted) return;
    setState(() => _isLoading = true);
    try {
      final statsData = await _statisticsService.getAllStats();
      if(mounted) {
        setState(() => _stats = statsData);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar estatísticas: $e')),
        );
      }
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Lista de estatísticas para exibição no grid
    final List<Map<String, dynamic>> statItems = [
      {'title': 'Total de Eventos', 'value': _stats['totalEvents'] ?? 0, 'icon': Icons.event, 'color': Colors.blue},
      {'title': 'Total de Escalas', 'value': _stats['totalScales'] ?? 0, 'icon': Icons.calendar_today, 'color': Colors.orange},
      {'title': 'Escalas Confirmadas', 'value': _stats['confirmedScales'] ?? 0, 'icon': Icons.check_circle, 'color': Colors.green},
      {'title': 'Total de Usuários', 'value': _stats['totalUsers'] ?? 0, 'icon': Icons.people, 'color': Colors.purple},
      {'title': 'Total de Voluntários', 'value': _stats['totalVolunteers'] ?? 0, 'icon': Icons.volunteer_activism, 'color': Colors.teal},
      {'title': 'Vagas em Aberto', 'value': _stats['openSlots'] ?? 0, 'icon': Icons.person_add_alt_1, 'color': Colors.red},
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Estatísticas', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary)),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchStatistics,
              child: GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 1.0,
                ),
                itemCount: statItems.length,
                itemBuilder: (context, index) {
                  final item = statItems[index];
                  return _StatCard(
                    title: item['title'],
                    value: item['value'].toString(),
                    icon: item['icon'],
                    color: item['color'],
                  );
                },
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shadowColor: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
