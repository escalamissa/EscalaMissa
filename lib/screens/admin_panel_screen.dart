import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Lista de itens do painel administrativo com títulos e subtítulos
    final List<Map<String, dynamic>> adminItems = [
      {
        'icon': Icons.church_outlined,
        'title': 'Paróquias',
        'subtitle': 'Gerenciar paróquias',
        'route': '/admin/parishes',
      },
      {
        'icon': Icons.groups_outlined,
        'title': 'Pastorais',
        'subtitle': 'Visualizar pastorais',
        'route': '/admin/pastorals',
      },
      {
        'icon': Icons.work_outline,
        'title': 'Funções',
        'subtitle': 'Definir funções e cargos',
        'route': '/admin/functions',
      },
      {
        'icon': Icons.event_outlined,
        'title': 'Eventos',
        'subtitle': 'Agendar missas e celebrações',
        'route': '/admin/events',
      },
      {
        'icon': Icons.calendar_today_outlined,
        'title': 'Escalas',
        'subtitle': 'Montar e gerenciar escalas',
        'route': '/admin/escalas',
      },
      {
        'icon': Icons.announcement_outlined,
        'title': 'Avisos',
        'subtitle': 'Publicar comunicados',
        'route': '/avisos',
      },
      {
        'icon': Icons.history_outlined,
        'title': 'Histórico',
        'subtitle': 'Ver participações',
        'route': '/history',
      },
      {
        'icon': Icons.bar_chart_outlined,
        'title': 'Estatísticas',
        'subtitle': 'Analisar dados',
        'route': '/admin/statistics',
      },
    ];

    final List<Color?> pastelColors = [
      Colors.blue[50],
      Colors.green[50],
      Colors.orange[50],
      Colors.purple[50],
      Colors.red[50],
      Colors.teal[50],
      Colors.amber[50],
      Colors.cyan[50],
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Painel Administrativo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 1,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 1.1,
        ),
        itemCount: adminItems.length,
        itemBuilder: (context, index) {
          final item = adminItems[index];
          final color = pastelColors[index % pastelColors.length];
          return _AdminMenuCard(
            title: item['title'],
            subtitle: item['subtitle'],
            icon: item['icon'],
            color: color,
            onTap: () => context.push(item['route']),
          );
        },
      ),
    );
  }
}

class _AdminMenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;

  const _AdminMenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: color ?? theme.cardColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 32.0, color: theme.colorScheme.primary),
              const Spacer(),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
