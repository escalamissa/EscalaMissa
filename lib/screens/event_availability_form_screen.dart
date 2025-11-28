import 'package:escala_missa/models/event.dart';
import 'package:escala_missa/models/pastoral.dart';
import 'package:escala_missa/models/app_function.dart';
import 'package:escala_missa/services/disponibilidade_service.dart';
import 'package:escala_missa/services/pastoral_service.dart';
import 'package:escala_missa/services/function_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class EventAvailabilityFormScreen extends StatefulWidget {
  final Evento event;

  const EventAvailabilityFormScreen({super.key, required this.event});

  @override
  State<EventAvailabilityFormScreen> createState() => _EventAvailabilityFormScreenState();
}

class _EventAvailabilityFormScreenState extends State<EventAvailabilityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedPastoralId;
  String? _selectedFunctionId;
  final _observacaoController = TextEditingController();

  final DisponibilidadeService _disponibilidadeService = DisponibilidadeService();
  final PastoralService _pastoralService = PastoralService();
  final FunctionService _functionService = FunctionService();

  List<Pastoral> _pastorals = [];
  List<AppFunction> _functions = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchDependencies();
  }

  Future<void> _fetchDependencies() async {
    setState(() => _isLoading = true);
    try {
      _pastorals = await _pastoralService.getPastorais();
      final fetchedFunctions = await _functionService.getFunctions();
      _functions = fetchedFunctions.map((funcMap) => AppFunction.fromMap(funcMap)).toList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar dependências: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAvailability() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      try {
        await _disponibilidadeService.createDisponibilidade(
          usuarioId: Supabase.instance.client.auth.currentUser!.id,
          pastoralId: _selectedPastoralId,
          funcaoId: _selectedFunctionId,
          dia: DateTime.parse(widget.event.data_hora),
          hora: widget.event.data_hora.isNotEmpty ? TimeOfDay.fromDateTime(DateTime.parse(widget.event.data_hora)) : null,
          observacao: _observacaoController.text.trim(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Disponibilidade salva com sucesso!')));
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar disponibilidade: $e')));
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
        title: Text('Marcar Disponibilidade', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary)),
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
                    _buildHeader(theme),
                    const SizedBox(height: 32),
                    DropdownButtonFormField<String?>(
                      value: _selectedPastoralId,
                      decoration: _inputDecoration(label: 'Pastoral (Opcional)', icon: Icons.groups_outlined, theme: theme),
                      items: [
                        const DropdownMenuItem<String?>(value: null, child: Text('Qualquer Pastoral', style: TextStyle(color: Colors.grey))),
                        ..._pastorals.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nome))).toList(),
                      ],
                      onChanged: (value) => setState(() => _selectedPastoralId = value),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String?>(
                      value: _selectedFunctionId,
                      decoration: _inputDecoration(label: 'Função (Opcional)', icon: Icons.work_outline, theme: theme),
                      items: [
                        const DropdownMenuItem<String?>(value: null, child: Text('Qualquer Função', style: TextStyle(color: Colors.grey))),
                        ..._functions.map((func) => DropdownMenuItem<String?>(value: func.id, child: Text(func.name))).toList(),
                      ],
                      onChanged: (value) => setState(() => _selectedFunctionId = value),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _observacaoController,
                      decoration: _inputDecoration(label: 'Observação (Opcional)', icon: Icons.description_outlined, theme: theme),
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveAvailability,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: _isSaving
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                          : const Text('Salvar Disponibilidade', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confirme sua disponibilidade para o evento:',
          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.event_outlined, color: theme.colorScheme.primary, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.event.titulo,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat("EEEE, dd 'de' MMMM 'às' HH:mm", 'pt_BR').format(DateTime.parse(widget.event.data_hora)),
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({required String label, IconData? icon, required ThemeData theme}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: theme.colorScheme.onSurfaceVariant) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: theme.colorScheme.surface,
    );
  }
}
