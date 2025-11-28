import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:escala_missa/models/event.dart';
import 'package:escala_missa/services/event_service.dart';

class EventSelectionScreen extends StatefulWidget {
  const EventSelectionScreen({super.key});

  @override
  State<EventSelectionScreen> createState() => _EventSelectionScreenState();
}

class _EventSelectionScreenState extends State<EventSelectionScreen> {
  final EventService _eventService = EventService();
  List<Evento> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      // Idealmente, o serviço buscaria apenas eventos com vagas em aberto.
      // Por enquanto, buscamos todos e ordenamos.
      final events = await _eventService.getEvents();
      if (mounted) {
        events.sort((a, b) => DateTime.parse(a.data_hora).compareTo(DateTime.parse(b.data_hora)));
        setState(() => _events = events);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar eventos: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Eventos com Vagas', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary)),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchEvents,
              child: _events.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.separated(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _events.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final event = _events[index];
                        return _EventSlotCard(event: event);
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
            Icon(Icons.event_available_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 24),
            Text('Nenhuma Vaga em Aberto', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('No momento, todos os postos estão preenchidos. Volte mais tarde para novas oportunidades!', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _EventSlotCard extends StatelessWidget {
  final Evento event;
  const _EventSlotCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventDateTime = DateTime.parse(event.data_hora);

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => context.push('/event_availability_form', extra: event),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                   Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children: [
                        Text(DateFormat('dd', 'pt_BR').format(eventDateTime), style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                        Text(DateFormat('MMM', 'pt_BR').format(eventDateTime).toUpperCase(), style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(event.titulo, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(DateFormat('HH:mm').format(eventDateTime), style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
             Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
                ),
                child: Center(
                  child: Text(
                    'Ver vagas e se voluntariar',
                    style: theme.textTheme.labelLarge?.copyWith(color: Colors.green.shade800, fontWeight: FontWeight.bold),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
