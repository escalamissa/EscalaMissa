import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:escala_missa/models/pastoral.dart';
import 'package:escala_missa/services/pastoral_service.dart';

class PastoralListScreen extends StatefulWidget {
  static const routeName = '/admin/pastorals';
  const PastoralListScreen({super.key});

  @override
  State<PastoralListScreen> createState() => _PastoralListScreenState();
}

class _PastoralListScreenState extends State<PastoralListScreen> {
  final PastoralService _pastoralService = PastoralService();
  List<Pastoral> _pastorais = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPastorais();
  }

  Future<void> _fetchPastorais() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final pastorais = await _pastoralService.getPastorais();
      if (mounted) {
        setState(() => _pastorais = pastorais);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar pastorais: $e')),
        );
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Gerenciar Pastorais',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchPastorais,
              child: _pastorais.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // Padding for FAB
                      itemCount: _pastorais.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final pastoral = _pastorais[index];
                        return _PastoralCard(pastoral: pastoral);
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/pastorals/new'),
        icon: const Icon(Icons.add),
        label: const Text('Nova Pastoral'),
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
            Icon(
              Icons.groups_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhuma Pastoral Cadastrada',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Adicione a primeira pastoral clicando no botão abaixo.',
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

class _PastoralCard extends StatelessWidget {
  final Pastoral pastoral;
  const _PastoralCard({required this.pastoral});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
          child: Icon(Icons.groups_outlined, color: theme.colorScheme.primary),
        ),
        title: Text(
          pastoral.nome,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Coordenador: ${pastoral.coordenador?.nome ?? 'Não definido'}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        trailing: Icon(Icons.edit_outlined, size: 20, color: Colors.grey[400]),
        onTap: () => context.push('/admin/pastorals/edit', extra: pastoral),
      ),
    );
  }
}
