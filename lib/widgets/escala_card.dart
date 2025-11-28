import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:escala_missa/models/escala.dart';

class EscalaCard extends StatelessWidget {
  final Escala escala;
  final bool canApprove;
  final VoidCallback? onApprove;
  final VoidCallback? onTap;

  const EscalaCard({
    super.key,
    required this.escala,
    this.canApprove = false,
    this.onApprove,
    this.onTap,
  });

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'confirmado':
        return Colors.green;
      case 'pendente':
        return Colors.orange;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventDateTime = DateTime.tryParse(escala.evento?.data_hora ?? '');
    final statusColor = _getStatusColor(escala.status);

    return Card(
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  if (eventDateTime != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        children: [
                          Text(DateFormat('dd', 'pt_BR').format(eventDateTime),
                              style: theme.textTheme.headlineSmall?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold)),
                          Text(
                              DateFormat('MMM', 'pt_BR')
                                  .format(eventDateTime)
                                  .toUpperCase(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${escala.evento?.titulo ?? 'Evento'}',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('${escala.funcao?.name ?? 'Função'}',
                            style: theme.textTheme.bodyLarge),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                            theme,
                            Icons.group_outlined,
                            escala.pastoral?.nome ??
                                'Pastoral não definida'),
                        const SizedBox(height: 4),
                        _buildInfoRow(theme, Icons.person_outline,
                            escala.voluntario?.nome ?? 'Vaga aberta'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (escala.status == 'pendente' && canApprove && onApprove != null)
              Container(
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12)),
                ),
                child: TextButton(
                  onPressed: onApprove,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    foregroundColor: Colors.green.shade800,
                  ),
                  child: const Text('Aprovar Escala',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Expanded(
            child: Text(text,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: Colors.grey[700]),
                overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
