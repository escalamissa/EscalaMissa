import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_user.dart';
import '../models/paroquia.dart';
import '../services/database_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _dbService = DatabaseService();
  final _currentUser = Supabase.instance.client.auth.currentUser;

  Perfil? _selectedPerfil;
  Paroquia? _selectedParoquia;
  List<Paroquia> _paroquias = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (_currentUser == null) {
      if(mounted) context.go('/login');
      return;
    }
    if(!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      final userProfile = await _dbService.getAppUser(_currentUser!.id);
      _paroquias = await _dbService.getParoquias();

      if (userProfile != null) {
        _nomeController.text = userProfile.nome;
        _telefoneController.text = userProfile.telefone ?? '';
        _selectedPerfil = userProfile.perfil;
        if (userProfile.paroquiaId != null && _paroquias.isNotEmpty) {
          _selectedParoquia = _paroquias.firstWhere((p) => p.id == userProfile.paroquiaId, orElse: () => _paroquias.first);
        }
      }
    } catch (e) {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar dados: $e')));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      if (!mounted) return;
      setState(() => _isSaving = true);

      try {
        final updatedUser = AppUser(
          id: _currentUser!.id,
          nome: _nomeController.text.trim(),
          telefone: _telefoneController.text.trim(),
          perfil: _selectedPerfil!,
          paroquiaId: _selectedParoquia?.id,
        );
        await _dbService.updateUserProfile(updatedUser);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil atualizado com sucesso!')));
        }
      } catch (e) {
          if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar perfil: $e')));
      } finally {
        if(mounted) setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (mounted) context.go('/login');
    } catch (e) {
       if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao sair: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Meu Perfil', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary)),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                children: [
                  _buildHeader(theme),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(controller: _nomeController, decoration: _inputDecoration(label: 'Nome Completo', icon: Icons.person_outline), validator: (v) => v!.isEmpty ? 'Insira seu nome' : null),
                          const SizedBox(height: 20),
                          TextFormField(controller: _telefoneController, decoration: _inputDecoration(label: 'Telefone', icon: Icons.phone_outlined)),
                           const SizedBox(height: 20),
                           DropdownButtonFormField<Paroquia>(
                            value: _selectedParoquia,
                            decoration: _inputDecoration(label: 'Paróquia', icon: Icons.church_outlined),
                            items: _paroquias.map((p) => DropdownMenuItem(value: p, child: Text(p.nome))).toList(),
                            onChanged: (v) => setState(() => _selectedParoquia = v),
                            validator: (v) => v == null ? 'Selecione sua paróquia' : null,
                           ),
                           const SizedBox(height: 20),
                           // O campo de perfil geralmente não é editável pelo usuário.
                           // Aqui, exibimos como read-only.
                           TextFormField(
                            initialValue: _selectedPerfil.toString().split('.').last,
                            readOnly: true,
                            decoration: _inputDecoration(label: 'Perfil', icon: Icons.verified_user_outlined, readOnly: true),
                           ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: _isSaving ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            child: _isSaving
                                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                                : const Text('Salvar Alterações', style: TextStyle(fontSize: 16)),
                          ),
                           const SizedBox(height: 16),
                           TextButton.icon(
                            icon: const Icon(Icons.logout),
                            label: const Text('Sair da Conta'),
                            onPressed: _signOut,
                            style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final name = _nomeController.text;
    final initials = name.isNotEmpty ? name.trim().split(' ').map((l) => l[0]).take(2).join() : '';

    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(initials, style: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
        ),
        const SizedBox(height: 12),
        Text(name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(_currentUser?.email ?? '', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600])),
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
    );
  }
}
