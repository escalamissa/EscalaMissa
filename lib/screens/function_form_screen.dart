import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:escala_missa/models/app_function.dart';
import 'package:escala_missa/services/function_service.dart';

class FunctionFormScreen extends StatefulWidget {
  final AppFunction? function;
  const FunctionFormScreen({super.key, this.function});

  @override
  State<FunctionFormScreen> createState() => _FunctionFormScreenState();
}

class _FunctionFormScreenState extends State<FunctionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  final FunctionService _functionService = FunctionService();
  bool _isSaving = false;

  bool get _isEditing => widget.function != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.function?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.function?.description ?? '');
  }

  Future<void> _saveFunction() async {
    if (_formKey.currentState!.validate()) {
      if (!mounted) return;
      setState(() => _isSaving = true);

      try {
        if (_isEditing) {
          await _functionService.updateFunction(
            id: widget.function!.id,
            nome: _nameController.text.trim(),
            descricao: _descriptionController.text.trim(),
          );
        } else {
          await _functionService.createFunction(
            nome: _nameController.text.trim(),
            descricao: _descriptionController.text.trim(),
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Função ${_isEditing ? 'atualizada' : 'salva'} com sucesso!')),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao salvar função: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Editar Função' : 'Nova Função',
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
                'Detalhes da Função',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Preencha o nome e a descrição da função.',
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration(
                  label: 'Nome da Função',
                  icon: Icons.work_outline,
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Por favor, insira o nome da função' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: _inputDecoration(
                  label: 'Descrição (Opcional)',
                  icon: Icons.description_outlined,
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveFunction,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : Text(
                        _isEditing ? 'Atualizar Função' : 'Salvar Função',
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
      alignLabelWithHint: true,
    );
  }
}
