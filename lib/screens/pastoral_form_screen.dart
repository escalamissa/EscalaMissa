import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:escala_missa/models/parish.dart';
import 'package:escala_missa/models/pastoral.dart';
import 'package:escala_missa/models/user_profile.dart';
import 'package:escala_missa/services/parish_service.dart';
import 'package:escala_missa/services/pastoral_service.dart';
import 'package:escala_missa/services/profile_service.dart';

class PastoralFormScreen extends StatefulWidget {
  final Pastoral? pastoral;
  const PastoralFormScreen({super.key, this.pastoral});

  @override
  State<PastoralFormScreen> createState() => _PastoralFormScreenState();
}

class _PastoralFormScreenState extends State<PastoralFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  String? _selectedParishId;
  String? _selectedCoordinatorId;

  final PastoralService _pastoralService = PastoralService();
  final ParishService _parishService = ParishService();
  final ProfileService _profileService = ProfileService();

  List<Parish> _parishes = [];
  List<UserProfile> _coordinators = [];
  bool _isLoading = true;
  bool _isSaving = false;

  bool get _isEditing => widget.pastoral != null;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.pastoral?.nome ?? '');
    if (_isEditing) {
      _selectedParishId = widget.pastoral!.paroquiaId;
      _selectedCoordinatorId = widget.pastoral!.coordenadorId;
    }
    _fetchDependencies();
  }

  Future<void> _fetchDependencies() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      _parishes = await _parishService.getParishes();
      _coordinators = await _profileService
          .getProfilesByRoles(['admin', 'padre', 'coordenador']);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dependências: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _savePastoral() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedParishId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione uma paróquia.')),
        );
        return;
      }
      if (!mounted) return;
      setState(() => _isSaving = true);

      try {
        final pastoralData = Pastoral(
          id: widget.pastoral?.id ?? '',
          nome: _nomeController.text.trim(),
          paroquiaId: _selectedParishId!,
          coordenadorId: _selectedCoordinatorId,
          ativa: widget.pastoral?.ativa ?? true,
        );

        if (_isEditing) {
          await _pastoralService.updatePastoral(pastoralData);
        } else {
          await _pastoralService.createPastoral(pastoralData);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Pastoral ${_isEditing ? 'atualizada' : 'salva'} com sucesso!')),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao salvar pastoral: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Editar Pastoral' : 'Nova Pastoral',
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Detalhes da Pastoral',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Preencha as informações para cadastrar ou editar uma pastoral.',
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _nomeController,
                      decoration: _inputDecoration(
                        label: 'Nome da Pastoral',
                        icon: Icons.groups_outlined,
                      ),
                      validator: (value) => value!.isEmpty
                          ? 'Por favor, insira o nome da pastoral'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedParishId,
                      decoration: _inputDecoration(
                        label: 'Paróquia',
                        icon: Icons.church_outlined,
                      ),
                      items: _parishes.map((parish) {
                        return DropdownMenuItem(
                          value: parish.id,
                          child: Text(parish.nome),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedParishId = value);
                      },
                      validator: (value) =>
                          value == null ? 'Selecione uma paróquia' : null,
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String?>(
                      value: _selectedCoordinatorId,
                      decoration: _inputDecoration(
                        label: 'Coordenador (Opcional)',
                        icon: Icons.person_outline,
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Nenhum', style: TextStyle(color: Colors.grey)),
                        ),
                        ..._coordinators.map((user) {
                          return DropdownMenuItem<String?>(
                            value: user.id,
                            child: Text(user.nome),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedCoordinatorId = value);
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _savePastoral,
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
                              _isEditing ? 'Atualizar Pastoral' : 'Salvar Pastoral',
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
