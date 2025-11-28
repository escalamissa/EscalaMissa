import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:escala_missa/models/escala.dart';
import 'package:escala_missa/services/personal_agenda_service.dart';
import 'package:escala_missa/widgets/escala_card.dart';

class PersonalAgendaScreen extends StatefulWidget {
  const PersonalAgendaScreen({super.key});

  @override
  State<PersonalAgendaScreen> createState() => _PersonalAgendaScreenState();
}

class _PersonalAgendaScreenState extends State<PersonalAgendaScreen> {
  final PersonalAgendaService _personalAgendaService = PersonalAgendaService();
  List<Escala> _myEscalas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyAgenda();
  }

  Future<void> _fetchMyAgenda() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      // Assume getMyAgenda now returns List<Escala>
      final escalas = await _personalAgendaService.getMyAgenda();
      if (mounted) {
        escalas.sort((a, b) => DateTime.parse(a.evento?.data_hora ?? '0')
            .compareTo(DateTime.parse(b.evento?.data_hora ?? '0')));
        setState(() {
          _myEscalas = escalas;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar sua agenda: $e')),
        );
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
        title: Text('Minha Agenda', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary)),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchMyAgenda,
              child: _myEscalas.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.separated(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _myEscalas.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final escala = _myEscalas[index];
                        return EscalaCard(
                          escala: escala,
                          // O usuário não pode aprovar sua própria escala nesta tela,
                          // então canApprove é false. O onTap pode levar a detalhes.
                          canApprove: false,
                          onTap: () {
                             // Ação opcional ao tocar no card, como mostrar um BottomSheet com detalhes.
                             ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(content: Text('Detalhes para a escala de ${escala.evento?.titulo}')),
                             );
                          },
                        );
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
            Icon(Icons.event_busy_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 24),
            Text(
              'Nenhuma Escala Encontrada',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Você ainda não foi escalado para nenhum evento. Verifique a tela de eventos ou suas disponibilidades.',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
