import 'package:cardiac_app/patient/basic-data.dart';
import 'package:cardiac_app/patient/patient_date.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'core/ecg_cubit.dart';
import 'core/risk_prediction_cubit.dart';
import 'notification/local_notification_service.dart';
import 'notification/notification.dart';
import 'nurse/NursePatientListScreen.dart';
import 'theme_provider.dart';
import 'alert.dart';
import 'nurse/dashboard.dart';
import 'auth/login.dart';
import 'profile.dart';
import 'auth/sign_up.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    await EasyLocalization.ensureInitialized();
    await LocalNotificationService.init();
    await NotificationService.initFCM();
  } catch (e, s) {
    debugPrint("🔥 Initialization error: $e");
    print(s);
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/langs',
      fallbackLocale: const Locale('en'),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => RiskPredictionCubit()),
          BlocProvider(create: (_) => ECGCubit()),
        ],
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ],
          child: const MyApp(),
        ),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ICU Cardiac Monitoring',
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.white,
        cardColor: Colors.white,
        primaryColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.blue),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.grey[900],
        cardColor: Colors.grey[850],
        primaryColor: Colors.blue[920],
        iconTheme: const IconThemeData(color: Colors.white),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
      ),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,

      // ❗ استخدم onGenerateRoute بدل routes عشان تبعت بيانات للشاشات
      onGenerateRoute: (settings) {
        if (settings.name == '/alerts') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => AlertScreen(currentUserRole: args['role']),
          );
        }

        // باقي الراوتات العادية
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/signup':
            return MaterialPageRoute(builder: (_) => const SignUpScreen());
          case '/profile':
            return MaterialPageRoute(builder: (_) => const ProfileScreen());
          case '/HomeScreen':
          case '/nurse_home':
          case '/doctor_home':
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          case '/patient_home':
            return MaterialPageRoute(builder: (_) => const BasicInfoScreen());
          case '/patient_profile':
            return MaterialPageRoute(builder: (_) => const PatientProfileScreen());
          case '/PatientList':
            return MaterialPageRoute(builder: (_) => const NursePatientListScreen());
          default:
            return null;
        }
      },
    );
  }
}
