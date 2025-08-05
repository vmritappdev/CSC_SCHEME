import 'package:csc/loginfolder/mpin%20login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:csc/app.dart';
import 'package:csc/dashboardscreens/notification.dart';
import 'package:csc/localization/provider.dart';
import 'package:csc/localization/localizationpro.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/app_config.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// 🔕 Background FCM Handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📩 BG Message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await initializeLocalNotifications();
  await _requestNotificationPermission();
  await _getFcmToken();
  _setupOnMessageListener();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  AppConfig(
    appName: 'CSC Dev',
    baseUrl: 'https://vmrdemos.com/csc_scheme',
    environment: Environment.dev,
  );

  final localizationProvider = LocalizationProvider();
  await localizationProvider.loadSavedLanguage();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => localizationProvider),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        title: 'CSC Dev',
        theme: ThemeData(primarySwatch: Colors.teal),
        home: const MyApp(),
      ),
    ),
  );

  /// ✅ Terminated case - after runApp
  WidgetsBinding.instance.addPostFrameCallback((_) {
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleNotificationClick(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNotificationClick(message);
    });
  });
}

void _handleNotificationClick(RemoteMessage message) async {
  print("✅ Notification Clicked!");

  // 👉 Login అయిపోయాక ఏ స్క్రీన్‌కి వెళ్ళాలో save చేస్తున్నాం
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('postLoginRedirect', 'notification');

  // 👉 LoginPage open అవుతుంది
  navigatorKey.currentState?.push(
  MaterialPageRoute(builder: (_) => const LoginPage()),
  );
}


Future<void> initializeLocalNotifications() async {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings = InitializationSettings(
  android: androidSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      print("📲 Local notification clicked");
      navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => NotificationScreen()),
      );
    },
  );

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'default_channel',
    'Default Notifications',
    description: 'Channel for CSC important notifications',
    importance: Importance.high,
    playSound: true,
  );

  await flutterLocalNotificationsPlugin
  .resolvePlatformSpecificImplementation<
    AndroidFlutterLocalNotificationsPlugin>()
    ?.createNotificationChannel(channel);
}

Future<void> _requestNotificationPermission() async {
  NotificationSettings settings =
      await FirebaseMessaging.instance.requestPermission();

  print('🔐 Permission: ${settings.authorizationStatus}');
}

Future<void> _getFcmToken() async {
  String? token = await FirebaseMessaging.instance.getToken();
  print('📱 FCM Token: $token');
}

void _setupOnMessageListener() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel',
            'Default Notifications',
            channelDescription: 'CSC Alerts',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            icon: '@mipmap/ic_launcher',
            ticker: 'ticker',
          ),
        ),
      );
    }
  });
}
