package br.edu.ifce.projetoapsback.model.bridge;

import lombok.AllArgsConstructor;

@AllArgsConstructor
public abstract class ReportAbstraction {

    protected ReportFormat reportFormat; // A Ponte

    // O método que delega a implementação para a ponte
    public abstract byte[] export(String content);

    public String getContentType() {
        return reportFormat.getContentType();
    }

    public String getExtension() {
        return reportFormat.getFileExtension();
    }
}