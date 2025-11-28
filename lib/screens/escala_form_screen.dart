import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:escala_missa/models/app_function.dart';
import 'package:escala_missa/models/event.dart';
import 'package:escala_missa/models/pastoral.dart';
import 'package:escala_missa/models/escala.dart' show Escala;
import 'package:escala_missa/models/user_profile.dart';
import 'package:escala_missa/services/escala_service.dart';
import 'package:escala_missa/services/event_service.dart';
import 'package:escala_missa/services/function_service.dart';
import 'package:escala_missa/services/pastoral_service.dart';
import 'package:escala_missa/services/profile_service.dart';

class EscalaFormScreen extends StatefulWidget {
  final Escala? escala;
  const EscalaFormScreen({super.key, this.escala});

  @override
  State<EscalaFormScreen> createState() => _EscalaFormScreenState();
}

class _EscalaFormScreenState extends State<EscalaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedEventId;
  String? _selectedPastoralId;
  String? _selectedFunctionId;
  String? _selectedVoluntarioId;
  final _observacaoController = TextEditingController();

  late EscalaService _escalaService;
  final EventService _eventService = EventService();
  final PastoralService _pastoralService = PastoralService();
  final FunctionService _functionService = FunctionService();
  final ProfileService _profileService = ProfileService();

  List<Evento> _events = [];
  List<Pastoral> _pastorals = [];
  List<AppFunction> _functions = [];
  List<UserProfile> _volunteers = [];
  bool _isLoading = true;
  bool _isSaving = false;

  bool get _isEditing => widget.escala != null;

  @override
  void initState() {
    super.initState();
    _escalaService = EscalaService();
    _fetchDependencies();

    if (_isEditing) {
      _selectedEventId = widget.escala!.eventId;
      _selectedPastoralId = widget.escala!.pastoralId;
      _selectedFunctionId = widget.escala!.functionId;
      _selectedVoluntarioId = widget.escala!.volunteerId;
      _observacaoController.text = widget.escala!.observation ?? '';
    }
  }

  Future<void> _fetchDependencies() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      _events = await _eventService.getEvents();
      _pastorals = await _pastoralService.getPastorais();
      final fetchedFunctions = await _functionService.getFunctions();
      _functions = fetchedFunctions.map((map) => AppFunction.fromMap(map)).toList();
      _volunteers = await _profileService.getProfilesByRoles(['voluntario']);

      // Using a Map to ensure uniqueness based on ID
      _events = {for (var e in _events) e.id: e}.values.toList();
      _pastorals = {for (var p in _pastorals) p.id: p}.values.toList();
      _functions = {for (var f in _functions) f.id: f}.values.toList();
      _volunteers = {for (var v in _volunteers) v.id: v}.values.toList();

      // After fetching, ensure the selected value exists in the list.
      // If not, set it to null to prevent the "zero" error.
      if (_selectedEventId != null && !_events.any((e) => e.id == _selectedEventId)) {
        _selectedEventId = null;
      }
      if (_selectedPastoralId != null && !_pastorals.any((p) => p.id == _selectedPastoralId)) {
        _selectedPastoralId = null;
      }
      if (_selectedFunctionId != null && !_functions.any((f) => f.id == _selectedFunctionId)) {
        _selectedFunctionId = null;
      }
      if (_selectedVoluntarioId != null && !_volunteers.any((v) => v.id == _selectedVoluntarioId)) {
        _selectedVoluntarioId = null;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar dependências: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveEscala() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedEventId == null || _selectedPastoralId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Evento e Pastoral são obrigatórios.')));
        return;
      }
      final parishId = _pastorals.firstWhere((p) => p.id == _selectedPastoralId).paroquiaId;

      if (!mounted) return;
      setState(() => _isSaving = true);
      
      try {
        final newEscala = Escala(
          id: widget.escala?.id,
          eventId: _selectedEventId!,
          pastoralId: _selectedPastoralId!,
          functionId: _selectedFunctionId,
          volunteerId: _selectedVoluntarioId,
          paroquiaId: parishId,
          observation: _observacaoController.text.trim(),
          status: widget.escala?.status ?? 'pendente',
        );

        if (_isEditing) {
          await _escalaService.updateEscala(newEscala);
        } else {
          await _escalaService.createEscala(newEscala);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Escala ${_isEditing ? 'atualizada' : 'criada'} com sucesso!')));
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar escala: $e')));
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }
  
  @override
  void dispose() {
    _observacaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Escala' : 'Nova Escala', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary)),
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
                    Text('Atribuir Voluntário', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Selecione o evento, a pastoral e o voluntário para montar a escala.', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600])),
                    const SizedBox(height: 32),
                    _buildDropdown(_events.map((e) => DropdownMenuItem(value: e.id, child: Text(e.titulo))).toList(), _selectedEventId, 'Evento', Icons.event_outlined, (value) => setState(() => _selectedEventId = value)),
                    const SizedBox(height: 20),
                    _buildDropdown(_pastorals.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nome))).toList(), _selectedPastoralId, 'Pastoral', Icons.groups_outlined, (value) => setState(() => _selectedPastoralId = value)),
                    const SizedBox(height: 20),
                    _buildDropdown(_functions.map((f) => DropdownMenuItem(value: f.id, child: Text(f.name))).toList(), _selectedFunctionId, 'Função (Opcional)', Icons.work_outline, (value) => setState(() => _selectedFunctionId = value), isOptional: true),
                    const SizedBox(height: 20),
                    _buildDropdown(_volunteers.map((v) => DropdownMenuItem(value: v.id, child: Text(v.nome))).toList(), _selectedVoluntarioId, 'Voluntário (Opcional)', Icons.person_outline, (value) => setState(() => _selectedVoluntarioId = value), isOptional: true),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _observacaoController,
                      decoration: _inputDecoration(label: 'Observação (Opcional)', icon: Icons.description_outlined),
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveEscala,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: _isSaving
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                          : Text(_isEditing ? 'Atualizar Escala' : 'Salvar Escala', style: const TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDropdown(List<DropdownMenuItem<String>> items, String? value, String label, IconData icon, ValueChanged<String?> onChanged, {bool isOptional = false}) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: _inputDecoration(label: label, icon: icon),
      items: items,
      onChanged: onChanged,
      validator: (val) {
        if (!isOptional && val == null) {
          return 'Este campo é obrigatório';
        }
        return null;
      },
    );
  }

  InputDecoration _inputDecoration({required String label, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
      alignLabelWithHint: true,
    );
  }
}
