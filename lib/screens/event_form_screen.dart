import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:escala_missa/models/event.dart';
import 'package:escala_missa/models/parish.dart';
import 'package:escala_missa/services/event_service.dart';
import 'package:escala_missa/services/liturgical_calendar_service.dart';
import 'package:escala_missa/services/parish_service.dart';

class EventFormScreen extends StatefulWidget {
  final Evento? evento;
  const EventFormScreen({super.key, this.evento});

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descricaoController;
  late TextEditingController _localController;
  late TextEditingController _tempoLiturgicoController;
  late TextEditingController _solenidadeController;

  String? _selectedParishId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final EventService _eventService = EventService();
  final ParishService _parishService = ParishService();
  final LiturgicalCalendarService _liturgicalCalendarService = LiturgicalCalendarService();
  List<Parish> _parishes = [];
  bool _isLoading = true;
  bool _isSaving = false;

  bool get _isEditing => widget.evento != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.evento?.titulo ?? '');
    _descricaoController = TextEditingController(text: widget.evento?.descricao ?? '');
    _localController = TextEditingController(text: widget.evento?.local ?? '');
    _tempoLiturgicoController = TextEditingController(text: widget.evento?.tempoLiturgico ?? '');
    _solenidadeController = TextEditingController(text: widget.evento?.solenidade ?? '');

    if (_isEditing) {
      _selectedParishId = widget.evento!.paroquiaId;
      final dateTime = DateTime.parse(widget.evento!.data_hora);
      _selectedDate = dateTime;
      _selectedTime = TimeOfDay.fromDateTime(dateTime);
    }

    _fetchDependencies();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descricaoController.dispose();
    _localController.dispose();
    _tempoLiturgicoController.dispose();
    _solenidadeController.dispose();
    super.dispose();
  }

  Future<void> _fetchDependencies() async {
    if(!mounted) return;
    setState(() => _isLoading = true);
    try {
      _parishes = await _parishService.getParishes();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar paróquias: $e')));
      }
    }
    if(mounted) setState(() => _isLoading = false);
  }

  Future<void> _fetchLiturgicalData(DateTime date) async {
    try {
      final liturgicalData = await _liturgicalCalendarService.getLiturgicalData(date);
      if (mounted && liturgicalData != null) {
        setState(() {
          _tempoLiturgicoController.text = liturgicalData['liturgia']?.toString() ?? '';
          final solenidade = liturgicalData['solenidade'];
          _solenidadeController.text = solenidade is Map ? solenidade['nome']?.toString() ?? '' : solenidade?.toString() ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao buscar liturgia: $e')));
      }
    }
  }

  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedParishId == null || _selectedDate == null || _selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, preencha todos os campos obrigatórios.')));
        return;
      }

      if(!mounted) return;
      setState(() => _isSaving = true);
      try {
        final fullDateTime = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, _selectedTime!.hour, _selectedTime!.minute);

        final eventoData = Evento(
          id: widget.evento?.id ?? '',
          paroquiaId: _selectedParishId!,
          titulo: _titleController.text.trim(),
          descricao: _descricaoController.text.trim(),
          data_hora: fullDateTime.toIso8601String(),
          local: _localController.text.trim(),
          tempoLiturgico: _tempoLiturgicoController.text.trim(),
          solenidade: _solenidadeController.text.trim(),
        );

        if (_isEditing) {
          await _eventService.updateEvent(eventoData.id, paroquiaId: eventoData.paroquiaId, title: eventoData.titulo, descricao: eventoData.descricao ?? '', dateTime: eventoData.data_hora, local: eventoData.local, tempoLiturgico: eventoData.tempoLiturgico, solenidade: eventoData.solenidade);
        } else {
          await _eventService.createEvent(eventoData, paroquiaId: eventoData.paroquiaId, title: eventoData.titulo, descricao: eventoData.descricao ?? '', dateTime: eventoData.data_hora, local: eventoData.local, tempoLiturgico: eventoData.tempoLiturgico, solenidade: eventoData.solenidade);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Evento ${_isEditing ? 'atualizado' : 'salvo'} com sucesso!')));
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar evento: $e')));
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      await _fetchLiturgicalData(picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Evento' : 'Novo Evento', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary)),
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
                    Text('Informações do Evento', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Preencha os detalhes do evento, como missas, celebrações ou reuniões.', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600])),
                    const SizedBox(height: 32),
                    TextFormField(controller: _titleController, decoration: _inputDecoration(label: 'Título do Evento', icon: Icons.title), validator: (value) => value!.isEmpty ? 'Por favor, insira o título' : null),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedParishId,
                      decoration: _inputDecoration(label: 'Paróquia', icon: Icons.church_outlined),
                      items: _parishes.map((parish) => DropdownMenuItem(value: parish.id, child: Text(parish.nome))).toList(),
                      onChanged: (value) => setState(() => _selectedParishId = value),
                      validator: (value) => value == null ? 'Selecione uma paróquia' : null,
                    ),
                    const SizedBox(height: 20),
                    _buildDateTimePicker(context, theme),
                    const SizedBox(height: 20),
                     TextFormField(controller: _localController, decoration: _inputDecoration(label: 'Local (Opcional)', icon: Icons.location_on_outlined)),
                    const SizedBox(height: 20),
                    TextFormField(controller: _descricaoController, decoration: _inputDecoration(label: 'Descrição (Opcional)', icon: Icons.description_outlined), maxLines: 3, textCapitalization: TextCapitalization.sentences),
                    const SizedBox(height: 20),
                     TextFormField(controller: _tempoLiturgicoController, decoration: _inputDecoration(label: 'Tempo Litúrgico', icon: Icons.wb_sunny_outlined, readOnly: true)),
                    const SizedBox(height: 20),
                    TextFormField(controller: _solenidadeController, decoration: _inputDecoration(label: 'Solenidade', icon: Icons.star_border, readOnly: true)),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveEvent,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                      ),
                      child: _isSaving
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                          : Text(_isEditing ? 'Atualizar Evento' : 'Salvar Evento', style: const TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDateTimePicker(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Data e Hora', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300)
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, color: Colors.grey),
                        const SizedBox(width: 12),
                        Text(
                          _selectedDate == null ? 'Selecionar Data' : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                           style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(width: 1, height: 40, color: Colors.grey.shade300),
              Expanded(
                child: InkWell(
                  onTap: () => _selectTime(context),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_outlined, color: Colors.grey),
                        const SizedBox(width: 12),
                        Text(
                          _selectedTime == null ? 'Selecionar Hora' : _selectedTime!.format(context),
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({required String label, IconData? icon, bool readOnly = false}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: readOnly ? Colors.grey.shade200 : Colors.white,
      alignLabelWithHint: true,
    );
  }
}
