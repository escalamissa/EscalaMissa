import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:escala_missa/models/app_function.dart';
import 'package:escala_missa/models/disponibilidade.dart';
import 'package:escala_missa/models/pastoral.dart';
import 'package:escala_missa/services/disponibilidade_service.dart';
import 'package:escala_missa/services/function_service.dart';
import 'package:escala_missa/services/pastoral_service.dart';

class DisponibilidadeScreen extends StatefulWidget {
  const DisponibilidadeScreen({super.key});

  @override
  State<DisponibilidadeScreen> createState() => _DisponibilidadeScreenState();
}

class _DisponibilidadeScreenState extends State<DisponibilidadeScreen> {
  final DisponibilidadeService _disponibilidadeService = DisponibilidadeService();
  List<Disponibilidade> _disponibilidades = [];
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
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final fetchedDisponibilidades = await _disponibilidadeService.getDisponibilidades(userId: userId);
      if (mounted) {
        fetchedDisponibilidades.sort((a, b) => DateTime.parse(b.dia).compareTo(DateTime.parse(a.dia)));
        setState(() => _disponibilidades = fetchedDisponibilidades);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar dados: $e')));
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _deleteDisponibilidade(String id) async {
    // ... (lógica de exclusão)
  }

  void _showAddAvailabilitySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => _AddDisponibilidadeForm(onAdd: () async {
        Navigator.of(ctx).pop();
        await _fetchData();
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Minhas Disponibilidades', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary)),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: _disponibilidades.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                      itemCount: _disponibilidades.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final disp = _disponibilidades[index];
                        return _DisponibilidadeCard(disponibilidade: disp, onDelete: () => _deleteDisponibilidade(disp.id!));
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAvailabilitySheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Adicionar'),
      ),
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    // ... (código do empty state, similar aos outros)
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 24),
            Text('Nenhuma Disponibilidade', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Clique no botão "Adicionar" para registrar os dias e horários em que você pode servir.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _DisponibilidadeCard extends StatelessWidget {
  // ... (código do card redesenhado)
  final Disponibilidade disponibilidade;
  final VoidCallback onDelete;

  const _DisponibilidadeCard({required this.disponibilidade, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dispDate = DateTime.parse(disponibilidade.dia);
    final TimeOfDay? dispTime = disponibilidade.hora != null ? TimeOfDay.fromDateTime(DateFormat('HH:mm:ss').parse(disponibilidade.hora!)) : null;

    return Card(
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      color: theme.colorScheme.primary.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Column(
              children: [
                Text(DateFormat('dd', 'pt_BR').format(dispDate), style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                Text(DateFormat('MMM', 'pt_BR').format(dispDate).toUpperCase(), style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    dispTime != null ? 'Disponível às ${dispTime.format(context)}' : 'Dia Inteiro',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (disponibilidade.pastoral != null) Text('Pastoral: ${disponibilidade.pastoral!.nome}', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
                  if (disponibilidade.funcao != null) Text('Função: ${disponibilidade.funcao!.name}', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
                   if (disponibilidade.observacao != null && disponibilidade.observacao!.isNotEmpty) ...[
                     const SizedBox(height: 4),
                     Text('Obs: ${disponibilidade.observacao!}', style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic, color: Colors.grey[600])),
                   ]
                ],
              ),
            ),
             IconButton(
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
              tooltip: 'Remover',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddDisponibilidadeForm extends StatefulWidget {
  final VoidCallback onAdd;
  const _AddDisponibilidadeForm({required this.onAdd});

  @override
  State<_AddDisponibilidadeForm> createState() => _AddDisponibilidadeFormState();
}

class _AddDisponibilidadeFormState extends State<_AddDisponibilidadeForm> {
  final DisponibilidadeService _disponibilidadeService = DisponibilidadeService();
  final PastoralService _pastoralService = PastoralService();
  final FunctionService _functionService = FunctionService();
  
  List<Pastoral> _pastorals = [];
  List<AppFunction> _functions = [];

  String? _selectedPastoralId;
  String? _selectedFunctionId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _observacaoController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchDependencies();
  }

  Future<void> _fetchDependencies() async {
     try {
      _pastorals = await _pastoralService.getPastorais();
      final fetchedFunctions = await _functionService.getFunctions();
      _functions = fetchedFunctions.map((map) => AppFunction.fromMap(map)).toList();
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar opções: $e')));
      }
    }
  }
  
  Future<void> _submit() async {
    if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, selecione uma data.')));
        return;
    }
    setState(() => _isSaving = true);
    try {
      await _disponibilidadeService.createDisponibilidade(
        usuarioId: Supabase.instance.client.auth.currentUser!.id,
        pastoralId: _selectedPastoralId,
        funcaoId: _selectedFunctionId,
        dia: _selectedDate!,
        hora: _selectedTime,
        observacao: _observacaoController.text.trim(),
      );
      widget.onAdd();
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
    } finally {
      if(mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.background,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Adicionar Disponibilidade', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Informe os dias e horários que você pode servir.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 24),
            _buildDateTimePicker(context, theme),
            const SizedBox(height: 20),
            DropdownButtonFormField<String?>(
              value: _selectedPastoralId,
              decoration: _inputDecoration(label: 'Pastoral (Opcional)', icon: Icons.groups_outlined, theme: theme),
              items: [
                const DropdownMenuItem<String?>(value: null, child: Text('Qualquer Pastoral', style: TextStyle(color: Colors.grey))),
                ..._pastorals.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nome))).toList()
              ],
              onChanged: (value) => setState(() => _selectedPastoralId = value),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String?>(
              value: _selectedFunctionId,
              decoration: _inputDecoration(label: 'Função (Opcional)', icon: Icons.work_outline, theme: theme),
              items: [
                const DropdownMenuItem<String?>(value: null, child: Text('Qualquer Função', style: TextStyle(color: Colors.grey))),
                ..._functions.map((f) => DropdownMenuItem(value: f.id, child: Text(f.name))).toList()
              ],
              onChanged: (value) => setState(() => _selectedFunctionId = value),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _observacaoController,
              decoration: _inputDecoration(label: 'Observação (Opcional)', icon: Icons.description_outlined, theme: theme),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSaving ? null : _submit,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: _isSaving
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                  : const Text('Adicionar', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimePicker(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Selecione a Data e Hora', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _DateTimePickerCard(
                icon: Icons.calendar_today_outlined,
                label: _selectedDate == null ? 'Data' : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(context: context, initialDate: _selectedDate ?? DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2101));
                  if (picked != null) setState(() => _selectedDate = picked);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _DateTimePickerCard(
                icon: Icons.access_time_outlined,
                label: _selectedTime == null ? 'Hora (Op.)' : _selectedTime!.format(context),
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(context: context, initialTime: _selectedTime ?? TimeOfDay.now());
                  if (picked != null) setState(() => _selectedTime = picked);
                },
              ),
            ),
          ],
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

class _DateTimePickerCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DateTimePickerCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Text(label, style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}

