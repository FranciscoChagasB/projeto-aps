import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'user_management_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Acessa o usuário logado para, por exemplo, exibir seu nome.
    final user = Provider.of<AuthProvider>(context, listen: false).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel Administrativo'),
        actions: [
          // Botão de Logout
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              // Chama o método de logout do provider
              await Provider.of<AuthProvider>(context, listen: false).logout();

              // Navega de volta para a tela de login, limpando a pilha de navegação anterior.
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Bem-vindo(a), ${user?.fullName ?? 'Admin'}!',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          const Text(
            'Funcionalidades',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const Divider(),

          // Abaixo, criamos "placeholders" para as futuras funcionalidades do admin.

          _buildFeatureCard(
            context,
            icon: Icons.people_outline,
            title: 'Gerenciar Usuários',
            subtitle:
                'Visualizar, editar e gerenciar todos os usuários do sistema.',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => const UserManagementScreen()),
              );
            },
          ),
          _buildFeatureCard(
            context,
            icon: Icons.bar_chart_outlined,
            title: 'Estatísticas de Uso',
            subtitle:
                'Relatórios sobre atividades, usuários ativos e progresso geral.',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => const UserManagementScreen()),
              );
            },
          ),
          _buildFeatureCard(
            context,
            icon: Icons.library_books_outlined,
            title: 'Gerenciar Conteúdo Global',
            subtitle: 'Moderar e gerenciar a biblioteca de atividades padrão.',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => const UserManagementScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  // Widget helper para criar os cards de funcionalidades de forma consistente.
  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, size: 40, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        onTap: onTap,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
