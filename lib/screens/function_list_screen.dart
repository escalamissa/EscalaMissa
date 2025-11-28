import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:escala_missa/services/function_service.dart';
import 'package:escala_missa/models/app_function.dart';

class FunctionListScreen extends StatefulWidget {
  static const routeName = '/admin/functions';
  const FunctionListScreen({super.key});

  @override
  State<FunctionListScreen> createState() => _FunctionListScreenState();
}

class _FunctionListScreenState extends State<FunctionListScreen> {
  final FunctionService _functionService = FunctionService();
  List<AppFunction> _functions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFunctions();
  }

  Future<void> _fetchFunctions() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final functionsData = await _functionService.getFunctions();
      if (mounted) {
        setState(() {
          _functions = functionsData
              .map((data) => AppFunction.fromMap(data))
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar funções: $e')),
        );
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteFunction(String id) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const Text('Tem certeza que deseja excluir esta função? Esta ação não pode ser desfeita.'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Excluir',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      if (!mounted) return;
      setState(() => _isLoading = true);
      try {
        await _functionService.deleteFunction(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Função excluída com sucesso!')),
          );
          await _fetchFunctions(); // Refresh list
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir função: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Gerenciar Funções',
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
              onRefresh: _fetchFunctions,
              child: _functions.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                      itemCount: _functions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final function = _functions[index];
                        return _FunctionCard(
                          function: function,
                          onEdit: () => context.push(
                            '/admin/functions/edit',
                            extra: function.toMap(),
                          ),
                          onDelete: () => _deleteFunction(function.id),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/functions/new'),
        icon: const Icon(Icons.add),
        label: const Text('Nova Função'),
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
            Icon(Icons.work_outline, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 24),
            Text(
              'Nenhuma Função Cadastrada',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Adicione a primeira função para organizar os voluntários nas escalas.',
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

class _FunctionCard extends StatelessWidget {
  final AppFunction function;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _FunctionCard({
    required this.function,
    required this.onEdit,
    required this.onDelete,
  });

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
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.only(left: 20, top: 12, bottom: 12, right: 8),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Icon(Icons.work_outline, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      function.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (function.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        function.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ]
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Editar',
                    onPressed: onEdit,
                    color: Colors.grey[600],
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                    tooltip: 'Excluir',
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
