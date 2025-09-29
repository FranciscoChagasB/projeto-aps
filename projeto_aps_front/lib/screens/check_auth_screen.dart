import 'package:flutter/material.dart';
import 'package:projeto_aps_front/screens/home_screen.dart';
import 'package:projeto_aps_front/screens/login_screen.dart';
import '../services/auth_service.dart';

class CheckAuthScreen extends StatefulWidget {
  const CheckAuthScreen({super.key});

  @override
  _CheckAuthScreenState createState() => _CheckAuthScreenState();
}

class _CheckAuthScreenState extends State<CheckAuthScreen> {
  @override
  void initState() {
    super.initState();
    _checkTokenAndNavigate();
  }

  Future<void> _checkTokenAndNavigate() async {
    final authService = AuthService();
    final token = await authService.getToken();

    // Pequeno delay para a transição ser mais suave
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) { // Garante que o widget ainda está na árvore
      if (token != null) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}