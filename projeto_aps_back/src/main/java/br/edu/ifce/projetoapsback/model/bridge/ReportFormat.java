package br.edu.ifce.projetoapsback.model.bridge;

public interface ReportFormat {
    byte[] generate(String title, String content);
    String getContentType();
    String getFileExtension();
}
