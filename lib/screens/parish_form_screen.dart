import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:escala_missa/models/parish.dart';
import 'package:escala_missa/services/parish_service.dart';

class ParishFormScreen extends StatefulWidget {
  final Parish? parish;
  const ParishFormScreen({super.key, this.parish});

  @override
  State<ParishFormScreen> createState() => _ParishFormScreenState();
}

class _ParishFormScreenState extends State<ParishFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _cityController;
  late TextEditingController _ufController;
  final ParishService _parishService = ParishService();
  bool _isLoading = false;

  bool get _isEditing => widget.parish != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.parish?.nome ?? '');
    _cityController = TextEditingController(text: widget.parish?.cidade ?? '');
    _ufController = TextEditingController(text: widget.parish?.uf ?? '');
  }

  Future<void> _saveParish() async {
    if (_formKey.currentState!.validate()) {
      if (!mounted) return;
      setState(() => _isLoading = true);

      try {
        final parish = Parish(
          id: widget.parish?.id,
          nome: _nameController.text.trim(),
          cidade: _cityController.text.trim(),
          uf: _ufController.text.trim(),
        );

        if (_isEditing) {
          await _parishService.updateParish(parish);
        } else {
          await _parishService.createParish(parish);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Paróquia ${_isEditing ? 'atualizada' : 'salva'} com sucesso!')),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao salvar paróquia: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _ufController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Editar Paróquia' : 'Nova Paróquia',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Detalhes da Paróquia',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Preencha as informações abaixo para cadastrar uma nova paróquia.',
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration(
                  label: 'Nome da Paróquia',
                  icon: Icons.church_outlined,
                ),
                validator: (value) => value!.isEmpty
                    ? 'Por favor, insira o nome da paróquia'
                    : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _cityController,
                decoration: _inputDecoration(
                  label: 'Cidade',
                  icon: Icons.location_city_outlined,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _ufController,
                decoration: _inputDecoration(
                  label: 'UF (Ex: MS)',
                  icon: Icons.map_outlined,
                ),
                maxLength: 2,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveParish,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : Text(
                        _isEditing ? 'Atualizar Paróquia' : 'Salvar Paróquia',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String label, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
