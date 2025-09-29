import 'package:flutter/material.dart';
import 'screens/check_auth_screen.dart';
import 'theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ConecTEA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const CheckAuthScreen(),
    );
  }
}
