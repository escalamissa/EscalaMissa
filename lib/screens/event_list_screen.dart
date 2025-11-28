import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart'; // For groupBy
import 'package:escala_missa/models/event.dart';
import 'package:escala_missa/services/event_service.dart';
import 'package:escala_missa/services/pdf_service.dart';

class EventListScreen extends StatefulWidget {
  static const routeName = '/admin/events';
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  final EventService _eventService = EventService();
  final PdfService _pdfService = PdfService();
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
      final events = await _eventService.getEvents();
      if (mounted) {
        // Sort events by date, most recent first
        events.sort((a, b) =>
            DateTime.parse(b.data_hora).compareTo(DateTime.parse(a.data_hora)));
        setState(() => _events = events);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar eventos: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Groups events by month and year
  Map<String, List<Evento>> _groupEventsByMonth() {
    return groupBy(_events, (Evento event) {
      final date = DateTime.parse(event.data_hora);
      return DateFormat('MMMM yyyy', 'pt_BR').format(date);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groupedEvents = _groupEventsByMonth();
    final months = groupedEvents.keys.toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Gerenciar Eventos', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary)),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 1,
        actions: [
          if (_events.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_outlined),
              tooltip: 'Exportar PDF',
              onPressed: () => _pdfService
                  .generateEventsPdf(_events.map((e) => e.toMap()).toList()),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchEvents,
              child: _events.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                      itemCount: months.length,
                      itemBuilder: (context, index) {
                        final month = months[index];
                        final eventsInMonth = groupedEvents[month]!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _MonthHeader(month: month),
                            ...eventsInMonth
                                .map((event) => _EventCard(event: event))
                                .toList(),
                          ],
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/events/new'),
        icon: const Icon(Icons.add),
        label: const Text('Novo Evento'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
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
            Icon(Icons.event_note_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 24),
            Text('Nenhum Evento Cadastrado', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Adicione o primeiro evento, como uma missa ou celebração, clicando no botão abaixo.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  final String month;
  const _MonthHeader({required this.month});

  @override
  Widget build(BuildContext context) {
    // Capitalize first letter
    final displayMonth = month.substring(0, 1).toUpperCase() + month.substring(1);
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 16, left: 8),
      child: Text(
        displayMonth,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}


class _EventCard extends StatelessWidget {
  final Evento event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventDateTime = DateTime.parse(event.data_hora);

    return Card(
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: theme.colorScheme.primary.withOpacity(0.05),
      child: InkWell(
        onTap: () => context.push('/admin/events/edit', extra: event),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('dd', 'pt_BR').format(eventDateTime),
                      style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      DateFormat('MMM', 'pt_BR').format(eventDateTime).toUpperCase(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.titulo,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('HH:mm').format(eventDateTime),
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                     if(event.local != null && event.local!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.local!,
                              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                     ]
                  ],
                ),
              ),
              Icon(Icons.edit_outlined, size: 20, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
