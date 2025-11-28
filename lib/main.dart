import 'package:escala_missa/screens/registration_screen.dart';
import 'package:escala_missa/screens/profile_screen.dart';
import 'package:escala_missa/screens/admin_panel_screen.dart';
import 'package:escala_missa/screens/parish_list_screen.dart';
import 'package:escala_missa/screens/parish_form_screen.dart';
import 'package:escala_missa/screens/pastoral_list_screen.dart';
import 'package:escala_missa/screens/pastoral_form_screen.dart';
import 'package:escala_missa/models/pastoral.dart';
import 'package:escala_missa/screens/function_list_screen.dart';
import 'package:escala_missa/screens/function_form_screen.dart';
import 'package:escala_missa/screens/event_list_screen.dart';
import 'package:escala_missa/screens/event_form_screen.dart';
import 'package:escala_missa/screens/escala_list_screen.dart';
import 'package:escala_missa/models/escala.dart';
import 'package:escala_missa/screens/escala_form_screen.dart';
import 'package:escala_missa/screens/disponibilidade_screen.dart';
import 'package:escala_missa/screens/personal_agenda_screen.dart';
import 'package:escala_missa/screens/aviso_list_screen.dart';
import 'package:escala_missa/screens/aviso_form_screen.dart';
import 'package:escala_missa/screens/volunteer_history_screen.dart';
import 'package:escala_missa/screens/statistics_screen.dart';
import 'package:escala_missa/screens/home_screen.dart';
import 'package:escala_missa/screens/login_screen.dart';
import 'package:escala_missa/screens/splash_screen.dart';
import 'package:escala_missa/screens/liturgy_screen.dart';
import 'package:escala_missa/screens/escala_confirmation_screen.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:escala_missa/screens/event_selection_screen.dart';
import 'package:escala_missa/models/event.dart';
import 'package:escala_missa/screens/event_availability_form_screen.dart';
import 'package:escala_missa/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:escala_missa/models/aviso.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:escala_missa/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:escala_missa/firebase_options.dart';
import 'package:escala_missa/models/app_function.dart'; // Import do modelo AppFunction

// Instância global do serviço de notificação.
// Pode ser acessado de qualquer lugar do app sem precisar ser passado como parâmetro.
late final NotificationService notificationService; // Modified to be late and non-final

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    print('Main: Before Firebase init');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Main: After Firebase init');

    print('Main: Loading .env...');
    await dotenv.load(fileName: "assets/.env");
    checkSupabaseCredentials();
    print('Main: Initializing Supabase...');
    await Supabase.initialize(url: supabaseUrl!, anonKey: supabaseAnonKey!); // Supabase initialized first
    print('Main: After Supabase init');

    notificationService = NotificationService(Supabase.instance.client); // Instantiated here
    print('Main: Before notification service init');
    await notificationService.initialize(); // Then notification service
    // await notificationService.scheduleDailyLiturgyReminder();
    print('Main: After notification service init');

    print('Main: Supabase initialized. Running app...');
    print('Main: Before runApp'); // Added
    runApp(const MyApp());
    print('Main: After runApp'); // Added
  } catch (e) {
    print('Error during app initialization: $e');
    runApp(
      MaterialApp(
        home: Scaffold(body: Center(child: Text('Error: $e'))),
      ),
    );
  }
}

// Configuração centralizada do GoRouter
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/profile', builder: (context, state) => ProfileScreen()),
    GoRoute(path: '/registration', builder: (context, state) => RegistrationScreen()),
    GoRoute(
      path: '/home',
      // CORREÇÃO: Não é mais necessário passar 'notificationService'
      builder: (context, state) =>
          ShowCaseWidget(builder: (context) => const HomeScreen()),
    ),
    GoRoute(
      path: '/liturgy',
      builder: (context, state) => const LiturgyScreen(),
    ),
    GoRoute(
      path: '/disponibilidades',
      builder: (context, state) => const DisponibilidadeScreen(),
    ),
    GoRoute(
      path: '/agenda',
      builder: (context, state) => const PersonalAgendaScreen(),
    ),
    GoRoute(
      path: AvisoListScreen.routeName,
      builder: (context, state) => const AvisoListScreen(),
    ),
    GoRoute(
      path: AvisoFormScreen.routeName,
      builder: (context, state) =>
          AvisoFormScreen(aviso: state.extra as Aviso?),
    ),
    GoRoute(
      path: VolunteerHistoryScreen.routeName,
      builder: (context, state) => const VolunteerHistoryScreen(),
    ),
    GoRoute(
      path: '/event_selection',
      builder: (context, state) => const EventSelectionScreen(),
    ),
    GoRoute(
      path: '/event_availability_form',
      builder: (context, state) {
        final evento = state.extra as Evento?;
        if (evento == null)
          return const Center(child: Text('Erro: Evento não encontrado.'));
        return EventAvailabilityFormScreen(event: evento);
      },
    ),
    GoRoute(
      path: '/escala_confirmation',
      builder: (context, state) {
        final escala = state.extra as Escala?;
        if (escala == null)
          return const Center(child: Text('Erro: Escala não encontrada.'));
        // CORREÇÃO: Não é mais necessário passar 'notificationService'
        return EscalaConfirmationScreen(
          escala: escala,
        );
      },
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => AdminPanelScreen(),
      routes: [
        GoRoute(
          path: 'parishes',
          builder: (context, state) => const ParishListScreen(),
        ),
        GoRoute(
          path: 'parishes/new',
          builder: (context, state) => const ParishFormScreen(),
        ),
        GoRoute(
          path: 'pastorals',
          builder: (context, state) => const PastoralListScreen(),
        ),
        GoRoute(
          path: 'pastorals/new',
          builder: (context, state) => const PastoralFormScreen(),
        ),
        GoRoute(
          path: 'pastorals/edit',
          builder: (context, state) =>
              PastoralFormScreen(pastoral: state.extra as Pastoral?),
        ),
        GoRoute(
          path: 'functions',
          builder: (context, state) => const FunctionListScreen(),
        ),
        GoRoute(
          path: 'functions/new',
          builder: (context, state) => const FunctionFormScreen(),
        ),
        GoRoute(
          path: 'functions/edit',
          // CORREÇÃO: Passa um objeto AppFunction, e não um Map genérico
          builder: (context, state) {
            final map = state.extra as Map<String, dynamic>?;
            final function = map != null ? AppFunction.fromMap(map) : null;
            return FunctionFormScreen(function: function);
          },
        ),
        GoRoute(
          path: 'events',
          builder: (context, state) => const EventListScreen(),
        ),
        GoRoute(
          path: 'events/new',
          builder: (context, state) => const EventFormScreen(),
        ),
        GoRoute(
          path: 'events/edit',
          builder: (context, state) =>
              EventFormScreen(evento: state.extra as Evento?),
        ),
        GoRoute(
          path: 'escalas',
          // CORREÇÃO: Não é mais necessário passar 'notificationService'
          builder: (context, state) =>
              EscalaListScreen(notificationService: notificationService),
        ),
        GoRoute(
          path: 'escalas/new',
          // CORREÇÃO: Não é mais necessário passar 'notificationService'
          builder: (context, state) =>
              EscalaFormScreen(),
        ),
        GoRoute(
          path: 'escalas/edit',
          // CORREÇÃO: Não é mais necessário passar 'notificationService'
          builder: (context, state) => EscalaFormScreen(
            escala: state.extra as Escala?,
          ),
        ),
        GoRoute(
          path: 'statistics',
          builder: (context, state) => const StatisticsScreen(),
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'UFMS - Escala Missa',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.lightBlue,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      routerConfig: _router,
    );
  }
}
