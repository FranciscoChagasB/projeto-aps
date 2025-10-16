import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:projeto_aps_front/providers/admin_provider.dart';
import 'package:projeto_aps_front/providers/auth_provider.dart';
import 'package:projeto_aps_front/providers/parent_provider.dart';
import 'package:projeto_aps_front/providers/plano_provider.dart';
import 'package:projeto_aps_front/providers/registro_provider.dart';
import 'package:projeto_aps_front/providers/therapist_provider.dart';
import 'package:projeto_aps_front/screens/auth/splash_screen.dart';
import 'package:provider/provider.dart';
import 'theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, RegistroProvider>(
          create: (_) => RegistroProvider(),
          update: (_, auth, registro) => registro!..update(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ParentProvider>(
          create: (_) => ParentProvider(),
          update: (_, auth, previousParent) => previousParent!..update(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, TherapistProvider>(
          create: (_) => TherapistProvider(),
          update: (_, auth, previousTherapist) =>
              previousTherapist!..update(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, AdminProvider>(
          create: (_) => AdminProvider(),
          update: (_, auth, admin) => admin!..update(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, PlanoProvider>(
          create: (_) => PlanoProvider(),
          update: (_, auth, plano) => plano!..update(auth),
        ),
      ],
      child: MaterialApp(
        title: 'TEA App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('pt', 'BR'),
          Locale('en', 'US'),
        ],
        locale: const Locale('pt', 'BR'),
        home: const SplashScreen(),
      ),
    );
  }
}
