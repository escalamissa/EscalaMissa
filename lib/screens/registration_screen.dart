import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_user.dart';
import '../models/paroquia.dart';
import '../services/database_service.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _dbService = DatabaseService();

  Perfil? _selectedPerfil = Perfil.fiel;
  Paroquia? _selectedParoquia;
  List<Paroquia> _paroquias = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadParoquias();
  }

  Future<void> _loadParoquias() async {
    _paroquias = await _dbService.getParoquias();
    if (_paroquias.isNotEmpty) {
      _selectedParoquia = _paroquias.first;
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await Supabase.instance.client.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final user = response.user;
        if (user != null) {
          final newUser = AppUser(
            id: user.id,
            nome: _nomeController.text,
            telefone: _telefoneController.text,
            perfil: _selectedPerfil!,
            paroquiaId: _selectedParoquia!.id,
          );
          await _dbService.updateUserProfile(newUser);

          if (mounted) {
            context.go('/home');
          }
        } else {
            if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Verifique seu e-mail para confirmação.'),
                    ),
                );
                context.pop();
            }
        }
      } on AuthException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message)),
          );
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset('assets/images/logo.png', height: 150),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'E-mail'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu e-mail';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(labelText: 'Senha'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira sua senha';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _nomeController,
                      decoration: InputDecoration(labelText: 'Nome'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu nome';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _telefoneController,
                      decoration: InputDecoration(labelText: 'Telefone'),
                    ),
                    DropdownButtonFormField<Perfil>(
                      value: _selectedPerfil,
                      decoration: InputDecoration(labelText: 'Perfil'),
                      items: [Perfil.voluntario, Perfil.fiel].map((Perfil perfil) {
                        return DropdownMenuItem<Perfil>(
                          value: perfil,
                          child: Text(perfil.toString().split('.').last),
                        );
                      }).toList(),
                      onChanged: (Perfil? newValue) {
                        setState(() {
                          _selectedPerfil = newValue;
                        });
                      },
                    ),
                    DropdownButtonFormField<Paroquia>(
                      value: _selectedParoquia,
                      decoration: InputDecoration(labelText: 'Paróquia'),
                      items: _paroquias.map((Paroquia paroquia) {
                        return DropdownMenuItem<Paroquia>(
                          value: paroquia,
                          child: Text(paroquia.nome),
                        );
                      }).toList(),
                      onChanged: (Paroquia? newValue) {
                        setState(() {
                          _selectedParoquia = newValue;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Campo obrigatório' : null,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _signUp,
                      child: Text('Cadastrar'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
