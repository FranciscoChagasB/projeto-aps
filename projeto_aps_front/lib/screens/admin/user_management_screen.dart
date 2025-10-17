import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/user_admin.dart';
import 'add_edit_user_screen.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final _nameFilterController = TextEditingController();
  final _emailFilterController = TextEditingController();
  final _cpfFilterController = TextEditingController();
  bool? _activeFilter;

  @override
  void initState() {
    super.initState();
    // Inicia a busca pelos usuários assim que a tela é carregada
    Future.microtask(
        () => Provider.of<AdminProvider>(context, listen: false).fetchUsers());
  }

  @override
  void dispose() {
    _nameFilterController.dispose();
    _emailFilterController.dispose();
    _cpfFilterController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final filters = <String, dynamic>{};
    if (_nameFilterController.text.isNotEmpty) {
      filters['fullName'] = _nameFilterController.text;
    }
    if (_emailFilterController.text.isNotEmpty) {
      filters['email'] = _emailFilterController.text;
    }
    if (_cpfFilterController.text.isNotEmpty) {
      filters['cpf'] = _cpfFilterController.text;
    }
    if (_activeFilter != null) {
      filters['active'] = _activeFilter.toString();
    }

    Provider.of<AdminProvider>(context, listen: false)
        .fetchUsers(filters: filters);
  }

  void _clearFilters() {
    _nameFilterController.clear();
    _emailFilterController.clear();
    _cpfFilterController.clear();
    setState(() {
      _activeFilter = null;
    });
    Provider.of<AdminProvider>(context, listen: false).fetchUsers(filters: {});
  }

  void _navigateToAddEditUser([UserAdmin? user]) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(builder: (ctx) => AddEditUserScreen(user: user)),
    )
        .then((_) {
      // Atualiza a lista quando retorna da tela de edição/criação
      Provider.of<AdminProvider>(context, listen: false).fetchUsers();
    });
  }

  void _confirmDelete(UserAdmin user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content:
            Text('Tem certeza que deseja excluir o usuário ${user.fullName}?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
            onPressed: () async {
              try {
                await Provider.of<AdminProvider>(context, listen: false)
                    .deleteUser(user.id);
                if (mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Usuário excluído com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciamento de Usuários'),
      ),
      body: Column(
        children: [
          // Painel de Filtros Expansível
          ExpansionTile(
            title: const Text('Filtros de Busca'),
            leading: const Icon(Icons.filter_list),
            initiallyExpanded: false,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameFilterController,
                        decoration: const InputDecoration(labelText: 'Nome'),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailFilterController,
                        decoration: const InputDecoration(labelText: 'Email'),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _cpfFilterController,
                        decoration: const InputDecoration(labelText: 'CPF'),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: DropdownButtonFormField<bool?>(
                          value: _activeFilter,
                          decoration:
                              const InputDecoration(labelText: 'Status'),
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(value: null, child: Text('Todos')),
                            DropdownMenuItem(value: true, child: Text('Ativo')),
                            DropdownMenuItem(
                                value: false, child: Text('Inativo')),
                          ],
                          onChanged: (value) =>
                              setState(() => _activeFilter = value),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        alignment: WrapAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _clearFilters,
                            child: const Text('Limpar Filtros'),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.search),
                            label: const Text('Buscar'),
                            onPressed: _applyFilters,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 1),
          // Lista de Usuários
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, adminProvider, child) {
                if (adminProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (adminProvider.error != null) {
                  return Center(child: Text('Erro: ${adminProvider.error}'));
                }
                if (adminProvider.users.isEmpty) {
                  return const Center(
                      child: Text('Nenhum usuário encontrado.'));
                }

                return RefreshIndicator(
                  onRefresh: () => adminProvider.fetchUsers(),
                  child: ListView.builder(
                    itemCount: adminProvider.users.length,
                    itemBuilder: (ctx, i) {
                      final user = adminProvider.users[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        child: ListTile(
                          leading: Icon(
                            user.isActive
                                ? Icons.check_circle
                                : Icons.do_not_disturb_on,
                            color: user.isActive ? Colors.green : Colors.grey,
                          ),
                          title: Text(
                            user.fullName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(user.email),
                          trailing: PopupMenuButton(
                            icon: const Icon(Icons.more_vert),
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                  value: 'edit', child: Text('Editar')),
                              const PopupMenuItem(
                                  value: 'delete', child: Text('Excluir')),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                _navigateToAddEditUser(user);
                              } else if (value == 'delete') {
                                _confirmDelete(user);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditUser(),
        tooltip: 'Adicionar Usuário',
        child: const Icon(Icons.add),
      ),
    );
  }
}
