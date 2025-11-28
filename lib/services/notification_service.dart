import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:timezone/data/latest.dart' as tzdata;
// import 'package:timezone/timezone.dart' as tz;

/// Handler para mensagens do Firebase em segundo plano.
/// PRECISA ser uma função de nível superior (fora de qualquer classe).
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Garante que o Firebase seja inicializado neste contexto.
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  // final FlutterLocalNotificationsPlugin _localNotifications =
  //     FlutterLocalNotificationsPlugin();
  final SupabaseClient _supabaseClient; // Added

  NotificationService(this._supabaseClient); // Modified constructor

  /// Inicializa todos os serviços de notificação (Firebase e Local).
  Future<void> initialize() async {
    // Inicializa o timezone para notificações agendadas.
    // tzdata.initializeTimeZones();

    // --- Configuração das Notificações Locais ---
    // const AndroidInitializationSettings initializationSettingsAndroid =
    //     AndroidInitializationSettings('@drawable/ic_stat_logo_escala');
    // const DarwinInitializationSettings initializationSettingsIOS =
    //     DarwinInitializationSettings();
    // const InitializationSettings initializationSettings =
    //     InitializationSettings(
    //       android: initializationSettingsAndroid,
    //       iOS: initializationSettingsIOS,
    //     );
    // await _localNotifications.initialize(initializationSettings);

    // --- Configuração do Firebase Messaging ---
    await _firebaseMessaging.requestPermission();

    // Obtém e salva o token FCM
    final String? token = await _firebaseMessaging.getToken();
    print("FCM Token: $token");
    _saveTokenToDatabase(token);

    // O token pode ser atualizado, então é bom escutar por mudanças.
    _firebaseMessaging.onTokenRefresh.listen(_saveTokenToDatabase);

    // Configura os handlers de mensagem
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// Salva o token FCM no perfil do usuário no Supabase.
  Future<void> _saveTokenToDatabase(String? token) async {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId != null && token != null) {
      try {
        await _supabaseClient
            .from('users')
            .update({'fcm_token': token})
            .eq('id', userId);
        print('Token FCM salvo para o usuário $userId');
      } catch (e) {
        print('Falha ao salvar token FCM: $e');
      }
    }
  }

  /// Exibe uma notificação local (geralmente para mensagens em primeiro plano).
  // void _showLocalNotification(RemoteMessage message) {
  //   final notification = message.notification;
  //   if (notification != null) {
  //     _localNotifications.show(
  //       notification.hashCode,
  //       notification.title,
  //       notification.body,
  //       const NotificationDetails(
  //         android: AndroidNotificationDetails(
  //           'high_importance_channel', // ID do Canal
  //           'High Importance Notifications', // Nome do Canal
  //           channelDescription:
  //               'Este canal é usado para notificações importantes.',
  //           importance: Importance.max,
  //           priority: Priority.high,
  //           icon: '@drawable/ic_stat_logo_escala',
  //         ),
  //         iOS: DarwinNotificationDetails(),
  //       ),
  //     );
  //   }
  // }

  /// Agenda um lembrete diário para a liturgia.
  // Future<void> scheduleDailyLiturgyReminder() async {
  //   await _localNotifications.zonedSchedule(
  //     0, // ID da notificação
  //     'Liturgia Diária',
  //     'Lembre-se de ler a liturgia de hoje!',
  //     _nextInstanceOfTime(8, 0), // Agenda para as 8:00 da manhã
  //     const NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         'liturgy_reminder_channel',
  //         'Lembretes de Liturgia',
  //         channelDescription: 'Lembrete diário para a leitura da liturgia.',
  //         importance: Importance.defaultImportance,
  //         priority: Priority.low,
  //       ),
  //     ),
  //     androidScheduleMode: AndroidScheduleMode.inexact,
  //     uiLocalNotificationDateInterpretation:
  //         UILocalNotificationDateInterpretation.absoluteTime,
  //     matchDateTimeComponents:
  //         DateTimeComponents.time, // Repete todos os dias neste horário
  //   );
  //   print('Lembrete diário de liturgia agendado para as 8:00.');
  // }

  /// Calcula a próxima ocorrência de um horário específico.
  // tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
  //   final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  //   tz.TZDateTime scheduledDate = tz.TZDateTime(
  //     tz.local,
  //     now.year,
  //     now.month,
  //     now.day,
  //     hour,
  //     minute,
  //   );
  //   if (scheduledDate.isBefore(now)) {
  //     scheduledDate = scheduledDate.add(const Duration(days: 1));
  //   }
  //   return scheduledDate;
  // }

  // Future<void> showAssignedToScaleNotification(
  //   String title,
  //   String body,
  // ) async {
  //   final AndroidNotificationDetails androidPlatformChannelSpecifics =
  //       AndroidNotificationDetails(
  //         'scale_assignment_channel_id', // id
  //         'Atribuição de Escala', // title
  //         channelDescription:
  //             'Notificação quando você é escalado para um evento',
  //         importance: Importance.max,
  //         priority: Priority.high,
  //       );
  //   final NotificationDetails platformChannelSpecifics = NotificationDetails(
  //     android: androidPlatformChannelSpecifics,
  //   );
  //   await _localNotifications.show(
  //     1, // Notification ID
  //     title,
  //     body,
  //     platformChannelSpecifics,
  //     payload: 'scale_assignment',
  //   );
  // }
}