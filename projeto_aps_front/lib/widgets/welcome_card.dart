import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_client.dart';
import '../screens/common/chat_screen.dart';

class WelcomeCard extends StatefulWidget {
  const WelcomeCard({super.key});

  @override
  State<WelcomeCard> createState() => WelcomeCardState();
}

class WelcomeCardState extends State<WelcomeCard> {
  String greeting = "Olá";
  String quote = "Carregando inspiração...";
  int unreadMessages = 0;
  bool isLoading = true;
  String? _error;
  int? targetCriancaId;
  String? targetCriancaName;

  @override
  void initState() {
    super.initState();
    _fetchHomeInfo();
  }

  Future<void> refresh() => _fetchHomeInfo();

  Future<void> _fetchHomeInfo() async {
    try {
      final dio = ApiClient().dio;
      final response = await dio.get('/home-info');
      
      if (mounted) {
        setState(() {
          greeting = response.data['greeting'] ?? "Olá";
          quote = response.data['quote'] ?? "Tenha um ótimo dia!";
          unreadMessages = (response.data['unreadMessages'] as num?)?.toInt() ?? 0;
          
          // Pega os dados de navegação
          targetCriancaId = response.data['lastMessageCriancaId'];
          targetCriancaName = response.data['lastMessageCriancaName'];
          
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          quote = "Estamos juntos nessa jornada!";
          isLoading = false;
        });
      }
    }
  }

  void _navigateToChat() async {
    if (targetCriancaId != null) {
      // Navega para o chat
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            criancaId: targetCriancaId!,
            titulo: targetCriancaName ?? "Chat",
          ),
        ),
      );
      // Quando voltar do chat, atualiza o card (para sumir o aviso vermelho)
      _fetchHomeInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final userName = user?.fullName.split(' ')[0] ?? 'Usuário';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$greeting, $userName!', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(user?.role == 'HEALTH_PROFESSIONAL' ? 'Terapeuta' : 'Responsável', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(Icons.spa, color: Colors.white, size: 28),
              ),
            ],
          ),
          
          const SizedBox(height: 20),

          if (!isLoading && unreadMessages > 0)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Material(
                  color: Colors.redAccent.withOpacity(0.9),
                  child: InkWell(
                    onTap: _navigateToChat,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.mark_chat_unread, color: Colors.white, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Você tem $unreadMessages novas mensagens!\nToque para responder.",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 14),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Colors.yellowAccent, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: isLoading
                      ? const LinearProgressIndicator(color: Colors.white, backgroundColor: Colors.white24)
                      : Text('"$quote"', style: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic, fontSize: 14)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}