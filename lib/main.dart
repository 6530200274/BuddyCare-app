import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:my_app/providers/booking_provider.dart';
import 'package:my_app/screens/pdpa_caregiver_screen.dart';
import 'package:my_app/screens/select_package_screen.dart';
import 'package:my_app/screens/signup_caregiver_screen.dart';
import 'package:my_app/screens/signup_customer_screen.dart';
import 'package:my_app/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'theme/app_colors.dart';
import 'providers/selected_package_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('th_TH');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SelectedPackageProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final orange = AppColors.primary;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Care Service',
      locale: const Locale('th', 'TH'),
      supportedLocales: const [Locale('th', 'TH'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Sarabun',

        colorScheme: ColorScheme.fromSeed(
          seedColor: orange,
          primary: orange,
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: AppColors.text,
        ),

        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.text,
          elevation: 0,
          iconTheme: IconThemeData(color: orange),
          titleTextStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
            fontFamily: 'Sarabun',
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: orange,
            foregroundColor: Colors.white,
          ),
        ),

        datePickerTheme: DatePickerThemeData(
          backgroundColor: Colors.white,
          headerBackgroundColor: orange,
          headerForegroundColor: Colors.white,
          dayForegroundColor: WidgetStateProperty.all(AppColors.text),
          yearForegroundColor: WidgetStateProperty.all(AppColors.text),
          todayForegroundColor: WidgetStateProperty.all(orange),
          todayBorder: BorderSide(color: orange),
          // ignore: deprecated_member_use
          dayOverlayColor: WidgetStateProperty.all(orange.withValues(alpha: 0.12)),
          confirmButtonStyle: TextButton.styleFrom(foregroundColor: orange),
          cancelButtonStyle: TextButton.styleFrom(foregroundColor: orange),
        ),
      ),
      // home: const SelectPackageScreen(),
      // home: const RecipientFormScreen(),
      // home: const MeetingPointScreen(),
      // home: const SelectDateTimeScreen(),
      //home: const SignupCustomerScreen(),
      //home: const SplashScreenSlideSmoothForward(),
      //home: const SignupCaregiverScreen()
      home: const PdpaCaregiverScreen(),
    );
  }
}
