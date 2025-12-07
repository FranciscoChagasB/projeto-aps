package br.edu.ifce.projetoapsback.model.bridge;

import org.springframework.stereotype.Component;

@Component("xmlFormat")
public class XmlReportFormat implements ReportFormat {

    @Override
    public byte[] generate(String title, String content) {
        // Construção manual simples de XML para não depender de DTOs complexos
        StringBuilder xml = new StringBuilder();
        xml.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
        xml.append("<report>\n");
        xml.append("  <title>").append(escapeXml(title)).append("</title>\n");
        xml.append("  <content>").append(escapeXml(content)).append("</content>\n");
        xml.append("</report>");

        return xml.toString().getBytes();
    }

    // Função para evitar quebra do XML
    private String escapeXml(String input) {
        if (input == null) return "";
        return input.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&apos;");
    }

    @Override
    public String getContentType() {
        return "application/xml";
    }

    @Override
    public String getFileExtension() {
        return ".xml";
    }

}
