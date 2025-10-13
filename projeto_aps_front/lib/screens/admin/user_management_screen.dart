import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Inicia a busca pelos usuários assim que a tela é carregada
    Future.microtask(() => 
      Provider.of<AdminProvider>(context, listen: false).fetchUsers()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciamento de Usuários'),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (adminProvider.error != null) {
            return Center(child: Text('Erro: ${adminProvider.error}'));
          }
          if (adminProvider.users.isEmpty) {
            return const Center(child: Text('Nenhum usuário encontrado.'));
          }

          return ListView.builder(
            itemCount: adminProvider.users.length,
            itemBuilder: (ctx, i) {
              final user = adminProvider.users[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.email),
                      Text('Perfil: ${user.roles.join(', ')}'),
                      Text('Criado em: ${DateFormat('dd/MM/yyyy').format(user.createdAt)}'),
                    ],
                  ),
                  trailing: Switch(
                    value: user.isActive,
                    onChanged: (newValue) {
                      // Chama o provider para atualizar o status no backend
                      adminProvider.updateUserStatus(user.id, newValue);
                    },
                    activeColor: Colors.green,
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}