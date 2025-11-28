import 'package:escala_missa/services/escala_service.dart';
import 'package:escala_missa/services/function_service.dart';
import 'package:escala_missa/services/pastoral_service.dart';
import 'package:escala_missa/services/profile_service.dart';
import 'package:escala_missa/models/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:escala_missa/models/pastoral.dart';
import 'package:escala_missa/models/app_function.dart';
import 'package:escala_missa/models/escala.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // --- Serviços ---

  final ProfileService _profileService = ProfileService();

  final PastoralService _pastoralService = PastoralService();

  late EscalaService _escalaService;

  final FunctionService _functionService = FunctionService();



  // --- Global Keys para o Showcase ---

  final GlobalKey _calendarKey = GlobalKey();

  final GlobalKey _myAgendaKey = GlobalKey();

  final GlobalKey _selectEventKey = GlobalKey();

  final GlobalKey _notificationsKey = GlobalKey();



  // --- Estado ---

  UserProfile? _userProfile;

  List<Pastoral> _pastorals = [];

  List<AppFunction> _functions = [];

  List<Escala> _selectedDayScales = [];

  Map<DateTime, List<Escala>> _scalesByDay = {};

  String? _selectedPastoralFilter;

  String? _selectedFunctionFilter;



  DateTime _focusedDay = DateTime.now();

  DateTime? _selectedDay;

  CalendarFormat _calendarFormat = CalendarFormat.month;



  bool _isLoading = true;



  @override

  void initState() {

    super.initState();

    _escalaService = EscalaService();

    final now = DateTime.now();

    _selectedDay = DateTime.utc(now.year, now.month, now.day);

    _fetchData().then((_) {

      _checkAndStartTour();

    });

  }



  Future<void> _checkAndStartTour() async {

    final prefs = await SharedPreferences.getInstance();

    final showTour = prefs.getBool('showHomeTour') ?? true;



    if (showTour) {

      WidgetsBinding.instance.addPostFrameCallback((_) {

        ShowCaseWidget.of(context).startShowCase([

          _calendarKey,

          _myAgendaKey,

          _selectEventKey,

          _notificationsKey,

        ]);

      });

      await prefs.setBool('showHomeTour', false);

    }

  }



  Future<void> _fetchData() async {

    if (!mounted) return;

    setState(() => _isLoading = true);

    try {

      _userProfile = await _profileService.getProfile();

      _pastorals = await _pastoralService.getPastorais();

      final fetchedFunctions = await _functionService.getFunctions();

      _functions = fetchedFunctions

          .map((funcMap) => AppFunction.fromMap(funcMap))

          .toList();

      await _fetchAllScalesAndGroup();

    } catch (e) {

      if (mounted) {

        ScaffoldMessenger.of(context)

            .showSnackBar(SnackBar(content: Text('Erro ao carregar dados: $e')));

      }

    } finally {

      if (mounted) setState(() => _isLoading = false);

    }

  }



  Future<void> _fetchAllScalesAndGroup() async {

    try {

      final allScales = await _escalaService.getEscalas();

      if (!mounted) return;



      _scalesByDay.clear();

      final currentUser = _userProfile;



      final filteredScales = allScales.where((escala) {

        if (currentUser == null) return false;

        final userRole = currentUser.perfil;

        if (userRole == 'admin' ||

            userRole == 'coordenador' ||

            userRole == 'padre') {

          return true;

        } else if (userRole == 'voluntario') {

          return escala.voluntario?.id == currentUser.id ||

              escala.voluntario == null;

        }

        return false;

      }).toList();



      for (var escala in filteredScales) {

        final eventDateTime = DateTime.tryParse(escala.evento?.data_hora ?? '');

        if (eventDateTime != null) {

          final day = DateTime.utc(

              eventDateTime.year, eventDateTime.month, eventDateTime.day);

          _scalesByDay.putIfAbsent(day, () => []).add(escala);

        }

      }

      _updateSelectedDayScales();

    } catch (e) {

      if (mounted) {

        ScaffoldMessenger.of(context)

            .showSnackBar(SnackBar(content: Text('Erro ao carregar escalas: $e')));

      }

    }

  }



  void _updateSelectedDayScales() {

    final scalesForDay = _scalesByDay[_selectedDay] ?? [];

    _selectedDayScales = scalesForDay.where((escala) {

      bool matchesPastoral = _selectedPastoralFilter == null ||

          escala.pastoral?.id == _selectedPastoralFilter;

      bool matchesFunction = _selectedFunctionFilter == null ||

          escala.funcao?.id == _selectedFunctionFilter;

      return matchesPastoral && matchesFunction;

    }).toList();

    // Ordenar por hora do evento

    _selectedDayScales.sort((a, b) {

      final aDate = DateTime.tryParse(a.evento?.data_hora ?? '');

      final bDate = DateTime.tryParse(b.evento?.data_hora ?? '');

      if (aDate == null || bDate == null) return 0;

      return aDate.compareTo(bDate);

    });

  }



  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {

    final normalizedSelectedDay =

        DateTime.utc(selectedDay.year, selectedDay.month, selectedDay.day);

    if (!isSameDay(_selectedDay, normalizedSelectedDay)) {

      setState(() {

        _selectedDay = normalizedSelectedDay;

        _focusedDay = focusedDay;

        _updateSelectedDayScales();

      });

    }

  }



  Future<void> _signOut() async {

    try {

      await Supabase.instance.client.auth.signOut();

      if (mounted) context.go('/login');

    } catch (e) {

      // Handle error

    }

  }



  @override

  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return Scaffold(

      backgroundColor: Colors.grey[50],

      appBar: AppBar(

        title: Text(

          'Escala Missa',

          style: TextStyle(

              color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold),

        ),

        backgroundColor: theme.colorScheme.primary,

        elevation: 1,

        actions: [

          IconButton(

            icon: const Icon(Icons.book_outlined),

            tooltip: 'Liturgia Diária',

            onPressed: () => context.push('/liturgy'),

            color: theme.colorScheme.onPrimary,

          ),

          Showcase(

            key: _notificationsKey,

            description: 'Aqui você verá os avisos e notificações.',

            child: IconButton(

              icon: const Icon(Icons.notifications_outlined),

              tooltip: 'Avisos',

              onPressed: () => context.push('/avisos'),

              color: theme.colorScheme.onPrimary,

            ),

          ),

          IconButton(

            icon: const Icon(Icons.logout),

            tooltip: 'Sair',

            onPressed: _signOut,

            color: theme.colorScheme.onPrimary,

          ),

        ],

      ),

      body: _isLoading

          ? const Center(child: CircularProgressIndicator())

          : RefreshIndicator(

              onRefresh: _fetchData,

              child: SingleChildScrollView(

                padding: const EdgeInsets.all(16.0),

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    _buildHeader(context, theme),

                    const SizedBox(height: 24),

                    _buildActionGrid(context),

                    const SizedBox(height: 24),

                    Showcase(

                      key: _calendarKey,

                      description: 'Selecione um dia para ver as escalas.',

                      child: _buildCalendar(context, theme),

                    ),

                    const SizedBox(height: 24),

                    _buildScaleList(context, theme),

                  ],

                ),

              ),

            ),

    );

  }



  Widget _buildHeader(BuildContext context, ThemeData theme) {

    return Padding(

      padding: const EdgeInsets.symmetric(horizontal: 8.0),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Text(

            'Bem-vindo(a), ${_userProfile?.nome ?? 'Usuário'}!',

            style: theme.textTheme.headlineSmall?.copyWith(

              fontWeight: FontWeight.bold,

              color: theme.colorScheme.onSurface,

            ),

          ),

          const SizedBox(height: 4),

          Text(

            'Perfil: ${_userProfile?.perfil ?? 'Não definido'}',

            style: theme.textTheme.titleMedium

                ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),

          ),

        ],

      ),

    );

  }



  Widget _buildActionGrid(BuildContext context) {

    // Ações são filtradas com base no perfil do usuário

    final actions = <Widget>[];

    if (_userProfile?.perfil == 'admin') {

      actions.add(_ActionCard(

        title: 'Painel Admin',

        icon: Icons.dashboard_customize_outlined,

        onTap: () => context.push('/admin'),

      ));

      actions.add(_ActionCard(

        title: 'Funções',

        icon: Icons.work_outline,

        onTap: () => context.push('/admin/functions'),

      ));

    }

    if (_userProfile?.perfil == 'voluntario') {

      actions.add(_ActionCard(

        title: 'Disponibilidade',

        icon: Icons.event_available_outlined,

        onTap: () => context.push('/disponibilidades'),

      ));

    }

    actions.add(

      Showcase(

        key: _myAgendaKey,

        description: 'Acesse sua agenda pessoal aqui.',

        child: _ActionCard(

          title: 'Minha Agenda',

          icon: Icons.calendar_today_outlined,

          onTap: () => context.push('/agenda'),

        ),

      ),

    );

    actions.add(

      Showcase(

        key: _selectEventKey,

        description: 'Selecione um evento para marcar sua disponibilidade.',

        child: _ActionCard(

          title: 'Selecionar Evento',

          icon: Icons.event_outlined,

          onTap: () => context.push('/event_selection'),

        ),

      ),

    );

    actions.add(_ActionCard(

      title: 'Mural de Avisos',

      icon: Icons.campaign_outlined,

      onTap: () => context.push('/avisos'),

    ));

    if (_userProfile?.perfil == 'voluntario') {

      actions.add(_ActionCard(

        title: 'Meu Histórico',

        icon: Icons.history_outlined,

        onTap: () => context.push('/history'),

      ));

    }



    return GridView.builder(

      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(

        crossAxisCount: 2,

        crossAxisSpacing: 12,

        mainAxisSpacing: 12,

        childAspectRatio: 2.8,

      ),

      itemCount: actions.length,

      itemBuilder: (context, index) => actions[index],

      shrinkWrap: true,

      physics: const NeverScrollableScrollPhysics(),

    );

  }



  Widget _buildCalendar(BuildContext context, ThemeData theme) {

    return Card(

      elevation: 2,

      shadowColor: Colors.black.withOpacity(0.1),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      child: Padding(

        padding: const EdgeInsets.all(8.0),

        child: TableCalendar(

          firstDay: DateTime.utc(2020),

          lastDay: DateTime.utc(2030),

          focusedDay: _focusedDay,

          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

          calendarFormat: _calendarFormat,

          locale: 'pt_BR',

          onDaySelected: _onDaySelected,

          onFormatChanged: (format) {

            if (_calendarFormat != format) {

              setState(() => _calendarFormat = format);

            }

          },

          onPageChanged: (focusedDay) {

            setState(() => _focusedDay = focusedDay);

          },

          headerStyle: HeaderStyle(

            formatButtonVisible: false,

            titleCentered: true,

            titleTextStyle: theme.textTheme.titleLarge!.copyWith(

              color: theme.colorScheme.primary,

              fontWeight: FontWeight.bold,

            ),

            leftChevronIcon:

                Icon(Icons.chevron_left, color: theme.colorScheme.primary),

            rightChevronIcon:

                Icon(Icons.chevron_right, color: theme.colorScheme.primary),

          ),

          calendarStyle: CalendarStyle(

            todayDecoration: BoxDecoration(

              color: theme.colorScheme.primary.withOpacity(0.2),

              shape: BoxShape.circle,

            ),

            selectedDecoration: BoxDecoration(

              color: theme.colorScheme.primary,

              shape: BoxShape.circle,

            ),

            markerDecoration: BoxDecoration(

              color: theme.colorScheme.secondary,

              shape: BoxShape.circle,

            ),

            markersMaxCount: 1,

            canMarkersOverflow: false,

            defaultTextStyle: TextStyle(color: theme.colorScheme.onSurface),

            weekendTextStyle: TextStyle(color: theme.colorScheme.primary),

          ),

          eventLoader: (day) {

            final normalizedDay = DateTime.utc(day.year, day.month, day.day);

            return _scalesByDay[normalizedDay] ?? [];

          },

        ),

      ),

    );

  }



  Widget _buildScaleList(BuildContext context, ThemeData theme) {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Padding(

          padding: const EdgeInsets.symmetric(horizontal: 8.0),

          child: Text(

            'Escalas para ${DateFormat('dd/MM/yyyy', 'pt_BR').format(_selectedDay!)}',

            style: theme.textTheme.headlineSmall

                ?.copyWith(fontWeight: FontWeight.w600),

          ),

        ),

        const SizedBox(height: 16),

        if (_selectedDayScales.isNotEmpty)

          Row(

            children: [

              Expanded(

                child: _buildFilterDropdown(

                  _pastorals,

                  _selectedPastoralFilter,

                  'Pastoral',

                  (value) {

                    setState(() {

                      _selectedPastoralFilter = value;

                      _updateSelectedDayScales();

                    });

                  },

                ),

              ),

              const SizedBox(width: 16),

              Expanded(

                child: _buildFilterDropdown(

                  _functions,

                  _selectedFunctionFilter,

                  'Função',

                  (value) {

                    setState(() {

                      _selectedFunctionFilter = value;

                      _updateSelectedDayScales();

                    });

                  },

                ),

              ),

            ],

          ),

        const SizedBox(height: 16),

        if (_selectedDayScales.isEmpty)

          const Center(

            child: Padding(

              padding: EdgeInsets.symmetric(vertical: 40.0),

              child: Text(

                'Nenhuma escala encontrada para este dia.',

                style: TextStyle(fontSize: 16, color: Colors.grey),

              ),

            ),

          )

        else

          ListView.separated(

            shrinkWrap: true,

            physics: const NeverScrollableScrollPhysics(),

            itemCount: _selectedDayScales.length,

            separatorBuilder: (_, __) => const SizedBox(height: 12),

            itemBuilder: (context, index) {

              final escala = _selectedDayScales[index];

              return _EscalaCard(

                escala: escala,

                onTap: () {

                  final userPerfil = _userProfile?.perfil;

                  if (userPerfil == 'admin' ||

                      userPerfil == 'coordenador' ||

                      userPerfil == 'padre') {

                    context.push('/admin/escalas/edit', extra: escala);

                  } else if (userPerfil == 'voluntario' && escala.voluntario?.id != _userProfile?.id) {

                     context.push('/escala_confirmation', extra: escala);

                  } else {

                    // Voluntário clicando na sua própria escala ou fiel

                    // Poderia abrir um bottom sheet com detalhes

                    ScaffoldMessenger.of(context).showSnackBar(

                      const SnackBar(

                        content: Text('Detalhes da escala (ação futura).'),

                      ),

                    );

                  }

                },

              );

            },

          ),

      ],

    );

  }



  Widget _buildFilterDropdown(

    List<dynamic> items,

    String? currentValue,

    String label,

    ValueChanged<String?> onChanged,

  ) {

    return DropdownButtonFormField<String?>(

      isExpanded: true,

      value: currentValue,

      decoration: InputDecoration(

        labelText: label,

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),

        filled: true,

        fillColor: Colors.white,

        contentPadding:

            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

      ),

      items: [

        const DropdownMenuItem<String?>(

            value: null, child: Text('Todas', style: TextStyle(color: Colors.grey))),

        ...items.map<DropdownMenuItem<String?>>((item) {

          String id;

          String name;

          if (item is Pastoral) {

            id = item.id;

            name = item.nome;

          } else if (item is AppFunction) {

            id = item.id;

            name = item.name;

          } else {

            return const DropdownMenuItem<String?>(child: Text('Item inválido'));

          }

          return DropdownMenuItem<String?>(value: id, child: Text(name));

        }).toList(),

      ],

      onChanged: onChanged,

    );

  }

}



class _ActionCard extends StatelessWidget {

  final String title;

  final IconData icon;

  final VoidCallback onTap;



  const _ActionCard({

    required this.title,

    required this.icon,

    required this.onTap,

  });



  @override

  Widget build(BuildContext context) {

    final theme = Theme.of(context);

        return Card(

          elevation: 0,

          color: theme.colorScheme.primary.withOpacity(0.1),

          shape: RoundedRectangleBorder(

            borderRadius: BorderRadius.circular(12),

            side: BorderSide(color: Colors.grey.shade200),

          ),

      child: InkWell(

        onTap: onTap,

        borderRadius: BorderRadius.circular(12),

        child: Center(

          child: Row(

            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              Icon(icon, color: theme.colorScheme.primary, size: 20),

              const SizedBox(width: 12),

              Flexible(

                child: Text(

                  title,

                  style: theme.textTheme.labelLarge?.copyWith(

                    color: theme.colorScheme.onSurface,

                    fontWeight: FontWeight.w600,

                  ),

                  overflow: TextOverflow.ellipsis,

                ),

              ),

            ],

          ),

        ),

      ),

    );

  }

}



class _EscalaCard extends StatelessWidget {

  final Escala escala;

  final VoidCallback? onTap;



  const _EscalaCard({required this.escala, this.onTap});



  Color _getStatusColor(String? status) {

    switch (status) {

      case 'confirmado':

        return Colors.green;

      case 'pendente':

        return Colors.orange;

      case 'cancelado':

        return Colors.red;

      default:

        return Colors.grey;

    }

  }



  IconData _getStatusIcon(String? status) {

     switch (status) {

      case 'confirmado':

        return Icons.check_circle_outline;

      case 'pendente':

        return Icons.hourglass_empty_outlined;

      case 'cancelado':

        return Icons.cancel_outlined;

      default:

        return Icons.help_outline;

    }

  }



  @override

  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    final DateTime? eventDateTime =

        DateTime.tryParse(escala.evento?.data_hora ?? '');



    if (eventDateTime == null) {

      return const Card(

        child: ListTile(title: Text('Data do evento inválida')),

      );

    }



    final voluntarioNome = escala.voluntario?.nome ?? 'Vaga aberta';

    final status = escala.status;

    final statusColor = _getStatusColor(status);



    return Card(

      elevation: 1,

      shadowColor: Colors.black.withOpacity(0.1),

      margin: const EdgeInsets.only(bottom: 0),

      shape: RoundedRectangleBorder(

        borderRadius: BorderRadius.circular(12),

      ),

      child: InkWell(

        onTap: onTap,

        borderRadius: BorderRadius.circular(12),

        child: IntrinsicHeight(

          child: Row(

            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [

              Container(

                width: 5,

                decoration: BoxDecoration(

                  color: statusColor,

                  borderRadius: const BorderRadius.only(

                    topLeft: Radius.circular(12),

                    bottomLeft: Radius.circular(12),

                  ),

                ),

              ),

              Padding(

                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),

                child: Column(

                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [

                    Text(

                      DateFormat('HH').format(eventDateTime),

                      style: theme.textTheme.titleLarge?.copyWith(

                        fontWeight: FontWeight.bold,

                        color: theme.colorScheme.primary,

                      ),

                    ),

                    Text(

                      DateFormat('mm').format(eventDateTime),

                      style: theme.textTheme.bodyMedium?.copyWith(

                        color: theme.colorScheme.onSurface.withOpacity(0.7),

                      ),

                    ),

                  ],

                ),

              ),

              Expanded(

                child: Padding(

                  padding: const EdgeInsets.symmetric(vertical: 12.0),

                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.start,

                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [

                      Text(

                        '${escala.evento?.titulo ?? 'Evento'} - ${escala.funcao?.name ?? 'Função'}',

                        style: theme.textTheme.titleMedium?.copyWith(

                          fontWeight: FontWeight.bold,

                        ),

                        maxLines: 1,

                        overflow: TextOverflow.ellipsis,

                      ),

                      const SizedBox(height: 4),

                      Text(

                        'Pastoral: ${escala.pastoral?.nome ?? 'N/A'}',

                        style: theme.textTheme.bodyMedium?.copyWith(

                          color: theme.colorScheme.onSurface.withOpacity(0.7),

                        ),

                         maxLines: 1,

                        overflow: TextOverflow.ellipsis,

                      ),

                      const SizedBox(height: 8),

                      Row(

                        children: [

                          Icon(

                            escala.voluntario != null ? Icons.person_outline : Icons.group_work_outlined,

                            size: 16,

                            color: theme.colorScheme.onSurface.withOpacity(0.7),

                          ),

                          const SizedBox(width: 6),

                          Expanded(

                            child: Text(

                              voluntarioNome,

                              style: theme.textTheme.bodyMedium?.copyWith(

                                fontStyle: escala.voluntario == null ? FontStyle.italic : FontStyle.normal,

                                color: theme.colorScheme.onSurface.withOpacity(0.9),

                              ),

                               overflow: TextOverflow.ellipsis,

                            ),

                          ),

                        ],

                      ),

                    ],

                  ),

                ),

              ),

               Padding(

                padding: const EdgeInsets.symmetric(horizontal: 16.0),

                child: Icon(

                  _getStatusIcon(status),

                  color: statusColor,

                  size: 28,

                ),

              ),

            ],

          ),

        ),

      ),

    );

  }

}
