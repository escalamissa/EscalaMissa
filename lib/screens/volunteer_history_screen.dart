import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:escala_missa/models/escala.dart';
import 'package:escala_missa/services/volunteer_history_service.dart';
import 'package:escala_missa/widgets/escala_card.dart';

class VolunteerHistoryScreen extends StatefulWidget {
  static const routeName = '/history';
  const VolunteerHistoryScreen({super.key});

  @override
  State<VolunteerHistoryScreen> createState() => _VolunteerHistoryScreenState();
}

class _VolunteerHistoryScreenState extends State<VolunteerHistoryScreen> {
  final VolunteerHistoryService _volunteerHistoryService = VolunteerHistoryService();
  List<Escala> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      // O serviço retorna List<Map<String, dynamic>>
      final historyData = await _volunteerHistoryService.getMyParticipationHistory();
      if (mounted) {
        // Faz o parse do mapa para o modelo Escala
        final List<Escala> history = historyData.map((data) => Escala.fromMap(data)).toList();
        
        // Ordena a lista de objetos Escala
         history.sort((a, b) => DateTime.parse(b.evento?.data_hora ?? '0')
            .compareTo(DateTime.parse(a.evento?.data_hora ?? '0')));
            
        setState(() => _history = history);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar histórico: $e')),
        );
      }
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Meu Histórico', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary)),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchHistory,
              child: _history.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.separated(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _history.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final escala = _history[index];
                        return EscalaCard(escala: escala);
                      },
                    ),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_toggle_off_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 24),
            Text(
              'Histórico Vazio',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Suas participações em eventos aparecerão aqui depois que acontecerem.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
