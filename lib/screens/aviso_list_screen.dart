import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:escala_missa/models/aviso.dart';
import 'package:escala_missa/models/user_profile.dart';
import 'package:escala_missa/services/aviso_service.dart';
import 'package:escala_missa/services/pdf_service.dart';
import 'package:escala_missa/services/profile_service.dart';

class AvisoListScreen extends StatefulWidget {
  static const routeName = '/avisos';
  const AvisoListScreen({super.key});

  @override
  State<AvisoListScreen> createState() => _AvisoListScreenState();
}

class _AvisoListScreenState extends State<AvisoListScreen> {
  final AvisoService _avisoService = AvisoService();
  final ProfileService _profileService = ProfileService();
  final PdfService _pdfService = PdfService();
  List<Aviso> _avisos = [];
  UserProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      _userProfile = await _profileService.getProfile();
      final avisos = await _avisoService.getAvisos();
      if (mounted) {
        avisos.sort((a, b) => b.criadoEm!.compareTo(a.criadoEm!));
        setState(() => _avisos = avisos);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar avisos: $e')));
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _deleteAviso(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza que deseja excluir este aviso?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Não')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Sim', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _avisoService.deleteAviso(id);
        await _fetchData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aviso excluído com sucesso!')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao excluir aviso: $e')));
        }
      }
    }
  }

  bool _canManageAvisos() {
    final userPerfil = _userProfile?.perfil;
    return userPerfil == 'admin' || userPerfil == 'padre' || userPerfil == 'coordenador';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canManage = _canManageAvisos();
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Mural de Avisos', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary)),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 1,
        actions: [
          if (canManage && _avisos.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_outlined),
              tooltip: 'Exportar PDF',
              onPressed: () => _pdfService.generateAvisosPdf(_avisos.map((e) => e.toMap()).toList()),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: _avisos.isEmpty
                  ? _buildEmptyState(context, canManage)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                      itemCount: _avisos.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final aviso = _avisos[index];
                        return _AvisoCard(
                          aviso: aviso,
                          canManage: canManage,
                          onDelete: () => _deleteAviso(aviso.id!),
                          onEdit: () => context.push('/aviso-form', extra: aviso),
                        );
                      },
                    ),
            ),
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/aviso-form'),
              icon: const Icon(Icons.add),
              label: const Text('Novo Aviso'),
            )
          : null,
    );
  }

  Widget _buildEmptyState(BuildContext context, bool canManage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.campaign_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 24),
            Text('Nenhum Aviso Publicado', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              canManage
                ? 'Crie o primeiro aviso para a comunidade clicando no botão abaixo.'
                : 'Fique atento! Novidades da paróquia aparecerão aqui.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AvisoCard extends StatelessWidget {
  final Aviso aviso;
  final bool canManage;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AvisoCard({required this.aviso, required this.canManage, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(aviso.titulo, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Por ${aviso.autor?.nome ?? 'Admin'} em ${DateFormat('dd/MM/yyyy \'às\' HH:mm').format(aviso.criadoEm!)}',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            const Divider(height: 24),
            Text(aviso.mensagem, style: theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
            if (canManage) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(icon: Icon(Icons.edit_outlined, color: Colors.grey[700]), tooltip: 'Editar', onPressed: onEdit),
                  IconButton(icon: Icon(Icons.delete_outline, color: theme.colorScheme.error), tooltip: 'Excluir', onPressed: onDelete),
                ],
              )
            ]
          ],
        ),
      ),
    );
  }
}
