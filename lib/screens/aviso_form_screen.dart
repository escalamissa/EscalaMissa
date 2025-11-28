import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:escala_missa/models/aviso.dart';
import 'package:escala_missa/models/parish.dart';
import 'package:escala_missa/models/pastoral.dart';
import 'package:escala_missa/services/aviso_service.dart';
import 'package:escala_missa/services/parish_service.dart';
import 'package:escala_missa/services/pastoral_service.dart';

class AvisoFormScreen extends StatefulWidget {
  static const routeName = '/aviso-form';
  final Aviso? aviso;

  const AvisoFormScreen({super.key, this.aviso});

  @override
  State<AvisoFormScreen> createState() => _AvisoFormScreenState();
}

class _AvisoFormScreenState extends State<AvisoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final AvisoService _avisoService = AvisoService();
  final ParishService _parishService = ParishService();
  final PastoralService _pastoralService = PastoralService();

  late TextEditingController _tituloController;
  late TextEditingController _mensagemController;
  String? _selectedParishId;
  String? _selectedPastoralId;

  List<Parish> _parishes = [];
  List<Pastoral> _pastorals = [];
  bool _isLoading = true;
  bool _isSaving = false;

  bool get _isEditing => widget.aviso != null;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.aviso?.titulo ?? '');
    _mensagemController = TextEditingController(text: widget.aviso?.mensagem ?? '');
    if (_isEditing) {
      _selectedParishId = widget.aviso!.paroquiaId;
      _selectedPastoralId = widget.aviso!.pastoralId;
    }
    _fetchDependencies();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _mensagemController.dispose();
    super.dispose();
  }

  Future<void> _fetchDependencies() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      _parishes = await _parishService.getParishes();
      _pastorals = await _pastoralService.getPastorais();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar dependências: $e')));
      }
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAviso() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedParishId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, selecione uma paróquia.')));
        return;
      }
      if (!mounted) return;
      setState(() => _isSaving = true);

      try {
        final newAviso = Aviso(
          id: widget.aviso?.id,
          titulo: _tituloController.text.trim(),
          mensagem: _mensagemController.text.trim(),
          paroquiaId: _selectedParishId!,
          pastoralId: _selectedPastoralId,
        );

        if (_isEditing) {
          await _avisoService.updateAviso(newAviso);
        } else {
          await _avisoService.createAviso(newAviso);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Aviso ${_isEditing ? 'atualizado' : 'publicado'} com sucesso!')));
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar aviso: $e')));
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Aviso' : 'Novo Aviso', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary)),
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
                    Text('Mural de Avisos', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Crie e edite avisos para a paróquia ou pastorais específicas.', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600])),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _tituloController,
                      decoration: _inputDecoration(label: 'Título', icon: Icons.title),
                      validator: (value) => (value == null || value.isEmpty) ? 'Por favor, insira um título' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _mensagemController,
                      decoration: _inputDecoration(label: 'Mensagem', icon: Icons.message_outlined),
                      maxLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                       validator: (value) => (value == null || value.isEmpty) ? 'Por favor, insira a mensagem' : null,
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedParishId,
                      decoration: _inputDecoration(label: 'Paróquia', icon: Icons.church_outlined),
                      items: _parishes.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nome))).toList(),
                      onChanged: (value) => setState(() => _selectedParishId = value),
                      validator: (value) => value == null ? 'Selecione uma paróquia' : null,
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String?>(
                      value: _selectedPastoralId,
                      decoration: _inputDecoration(label: 'Pastoral (Opcional)', icon: Icons.groups_outlined),
                      items: [
                        const DropdownMenuItem<String?>(value: null, child: Text('Geral (Nenhuma)', style: TextStyle(color: Colors.grey))),
                        ..._pastorals.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nome))).toList()
                      ],
                      onChanged: (value) => setState(() => _selectedPastoralId = value),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveAviso,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: _isSaving
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                          : Text(_isEditing ? 'Atualizar Aviso' : 'Publicar Aviso', style: const TextStyle(fontSize: 16)),
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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
      alignLabelWithHint: true,
    );
  }
}
