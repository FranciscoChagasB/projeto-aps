import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'api_client.dart';

class AiService {
  final Dio _dio = ApiClient().dio;

  // 1. Gera o relatório em texto para visualização rápida
  Future<String> generateReportText(int criancaId) async {
    try {
      final response = await _dio.get('/ai/relatorio/crianca/$criancaId');
      return response.data['relatorio'];
    } on DioException catch (e) {
      throw Exception('Erro ao gerar relatório: ${e.response?.data ?? e.message}');
    }
  }

  Future<String> downloadReport(int criancaId, String format) async {
    try {
      Directory? dir;
      if (Platform.isAndroid) {
        dir = await getExternalStorageDirectory();
      } else {
        dir = await getApplicationDocumentsDirectory();
      }
      
      // Define a extensão correta
      final extension = format == 'pdf' ? 'pdf' : 'xml';
      final String savePath = '${dir!.path}/relatorio_$criancaId.$extension';

      await _dio.download(
        '/ai/relatorio/crianca/$criancaId/download?format=$format',
        savePath,
      );

      return savePath;
    } on DioException catch (e) {
      throw Exception('Erro ao baixar $format: ${e.message}');
    }
  }
}