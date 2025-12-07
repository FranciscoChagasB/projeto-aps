import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import '../../providers/ai_report_provider.dart';

class AiReportScreen extends StatefulWidget {
  final int criancaId;
  final String nomeCrianca;

  const AiReportScreen({
    super.key, 
    required this.criancaId, 
    required this.nomeCrianca
  });

  @override
  State<AiReportScreen> createState() => _AiReportScreenState();
}

class _AiReportScreenState extends State<AiReportScreen> {
  String? _reportContent;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReport();
    });
  }

  Future<void> _loadReport() async {
    final content = await Provider.of<AiReportProvider>(context, listen: false)
        .getReport(widget.criancaId);
    
    if (mounted) {
      setState(() {
        _reportContent = content;
      });
    }
  }

  Future<void> _downloadAndOpen(String format) async {
    final aiProvider = Provider.of<AiReportProvider>(context, listen: false);
    final path = await aiProvider.downloadFile(widget.criancaId, format);

    if (path != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Relatório ($format) salvo!'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'ABRIR',
            textColor: Colors.white,
            onPressed: () => OpenFilex.open(path),
          ),
        ),
      );
      OpenFilex.open(path);
    } else if (aiProvider.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(aiProvider.error!), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AiReportProvider>(
      builder: (context, aiProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Relatório Inteligente 🤖'),
            actions: [
              if (aiProvider.isDownloading)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)),
                )
              else
                PopupMenuButton<String>(
                  icon: const Icon(Icons.download),
                  tooltip: 'Baixar Relatório',
                  enabled: _reportContent != null, // Só habilita se tiver conteúdo
                  onSelected: (format) => _downloadAndOpen(format),
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'pdf',
                      child: ListTile(
                        leading: Icon(Icons.picture_as_pdf, color: Colors.red),
                        title: Text('Baixar PDF'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'xml',
                      child: ListTile(
                        leading: Icon(Icons.code, color: Colors.blue),
                        title: Text('Baixar XML'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          body: Builder(
            builder: (ctx) {
              if (aiProvider.isLoading) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text('A Inteligência Artificial está analisando o progresso...'),
                    ],
                  ),
                );
              }

              if (aiProvider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Erro: ${aiProvider.error}',
                            textAlign: TextAlign.center),
                      ),
                      ElevatedButton(
                          onPressed: _loadReport,
                          child: const Text('Tentar Novamente'))
                    ],
                  ),
                );
              }

              if (_reportContent == null) {
                return const Center(child: Text('Nenhum dado disponível.'));
              }

              return Markdown(
                data: _reportContent!,
                padding: const EdgeInsets.all(16.0),
                styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                  h1: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue),
                  p: const TextStyle(fontSize: 16, height: 1.5),
                ),
              );
            },
          ),
        );
      },
    );
  }
}