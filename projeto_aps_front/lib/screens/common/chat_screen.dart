import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  final int criancaId;
  final String titulo; // Nome da criança ou "Chat com Terapeuta"

  const ChatScreen({super.key, required this.criancaId, required this.titulo});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ChatProvider>(context, listen: false);
    provider.startPolling(widget.criancaId); // Começa a buscar mensagens
  }

  @override
  void dispose() {
    Provider.of<ChatProvider>(context, listen: false).stopPolling(); // Para a busca
    super.dispose();
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    
    final content = _controller.text;
    _controller.clear();
    
    try {
      await Provider.of<ChatProvider>(context, listen: false)
          .sendMessage(widget.criancaId, content);
      
      // Rola para o final após enviar
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao enviar")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.titulo)),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, _) {
                if (provider.messages.isEmpty) {
                  return const Center(child: Text("Nenhuma mensagem ainda."));
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.messages.length,
                  itemBuilder: (ctx, i) {
                    final msg = provider.messages[i];
                    final isMe = msg.isMine;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue[100] : Colors.grey[200],
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(12),
                            topRight: const Radius.circular(12),
                            bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
                            bottomRight: isMe ? Radius.zero : const Radius.circular(12),
                          ),
                        ),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isMe) ...[
                              Text(msg.senderName, style: TextStyle(fontSize: 10, color: Colors.grey[800], fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                            ],
                            Text(msg.content, style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Digite sua mensagem...",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}