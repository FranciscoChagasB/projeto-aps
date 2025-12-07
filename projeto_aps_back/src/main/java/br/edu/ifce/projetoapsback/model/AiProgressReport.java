package br.edu.ifce.projetoapsback.model;

import br.edu.ifce.projetoapsback.model.bridge.ReportAbstraction;
import br.edu.ifce.projetoapsback.model.bridge.ReportFormat;

public class AiProgressReport extends ReportAbstraction {

    private final String childName;

    public AiProgressReport(ReportFormat reportFormat, String childName) {
        super(reportFormat);
        this.childName = childName;
    }

    @Override
    public byte[] export(String aiContent) {
        // A abstração pode adicionar lógica de negócio antes de chamar a implementação
        String title = "Relatório de Progresso - " + childName;

        // Delega para a implementação escolhida (PDF ou XML)
        return reportFormat.generate(title, aiContent);
    }
}