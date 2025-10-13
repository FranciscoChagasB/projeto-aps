import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../admin/admin_dashboard_screen.dart';
import '../parent/parent_dashboard_screen.dart';
import '../therapist/therapist_dashboard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.user == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Usamos um switch para verificar a 'role' do usuário e retornar a tela apropriada.
        switch (authProvider.user?.role) {
          case 'PARENT':
            return const ParentDashboardScreen();
          case 'HEALTH_PROFESSIONAL':
            return const TherapistDashboardScreen();
          case 'ADMINISTRATOR':
            return const AdminDashboardScreen();
          
          // Caso padrão para qualquer situação inesperada (ex: role desconhecida).
          default:
            print('Role desconhecida: ${authProvider.user?.role}');
            return const Scaffold(
              body: Center(
                child: Text('Erro: Perfil de usuário não reconhecido.'),
              ),
            );
        }
      },
    );
  }
}