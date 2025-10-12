package br.edu.ifce.projetoapsback.model.dto;

import br.edu.ifce.projetoapsback.model.Atividade;

public record AtividadeSummaryDto(Integer id, String titulo) {
    public AtividadeSummaryDto(Atividade atividade) {
        this(atividade.getId(), atividade.getTitulo());
    }
}