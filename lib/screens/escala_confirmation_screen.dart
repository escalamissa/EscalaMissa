import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:escala_missa/models/escala.dart';
import 'package:escala_missa/services/escala_service.dart';

class EscalaConfirmationScreen extends StatefulWidget {
  final Escala escala;

  // A notificationService não é mais necessária aqui se a lógica for centralizada
  const EscalaConfirmationScreen({super.key, required this.escala});

  @override
  State<EscalaConfirmationScreen> createState() =>
      _EscalaConfirmationScreenState();
}

class _EscalaConfirmationScreenState extends State<EscalaConfirmationScreen> {
  late EscalaService _escalaService;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _escalaService = EscalaService();
  }

  Future<void> _updateStatus(String status) async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final escalaId = widget.escala.id;
    if (escalaId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro: ID da escala não encontrado.')),
        );
        setState(() => _isLoading = false);
      }
      return;
    }

    try {
      await _escalaService.updateEscalaStatus(
        id: escalaId,
        status: status,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Escala ${status == 'confirmado' ? 'confirmada' : 'recusada'} com sucesso!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar escala: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventDateTime = DateTime.parse(widget.escala.evento?.data_hora ?? '');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Convite de Escala',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimary)),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Você pode servir nesta escala?',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Você foi convidado(a) para a função de ${widget.escala.funcao?.name ?? 'não especificada'} no evento abaixo. Por favor, confirme ou recuse sua participação.',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 1,
              shadowColor: Colors.black.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDetailRow(theme, Icons.event_outlined, 'Evento',
                        widget.escala.evento?.titulo ?? 'N/A'),
                    const Divider(height: 24),
                    _buildDetailRow(
                        theme,
                        Icons.calendar_month_outlined,
                        'Data',
                        DateFormat("EEEE, dd 'de' MMMM", 'pt_BR')
                            .format(eventDateTime)),
                    const Divider(height: 24),
                    _buildDetailRow(
                        theme,
                        Icons.access_time_outlined,
                        'Hora',
                        DateFormat('HH:mm').format(eventDateTime)),
                     const Divider(height: 24),
                     _buildDetailRow(theme, Icons.groups_outlined, 'Pastoral', widget.escala.pastoral?.nome ?? 'N/A'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   ElevatedButton(
                    onPressed: () => _updateStatus('confirmado'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Confirmar Participação', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => _updateStatus('cancelado'),
                     style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                    child: const Text('Não posso / Recusar'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
