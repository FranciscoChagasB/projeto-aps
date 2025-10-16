package br.edu.ifce.projetoapsback.model.response;

import br.edu.ifce.projetoapsback.model.Atividade;
import br.edu.ifce.projetoapsback.model.PlanoDeAtividade;
import br.edu.ifce.projetoapsback.model.enumeration.TipoAtividade;

import java.util.List;

public record AtividadeResponseDto(
        Integer id,
        String titulo,
        String descricaoDetalhada,
        Integer duracaoEstimadaMinutos,
        TipoAtividade tipo
) {
    // Construtor de conveniência para mapear da entidade para o DTO
    public AtividadeResponseDto(Atividade atividade) {
        this(
                atividade.getId(),
                atividade.getTitulo(),
                atividade.getDescricaoDetalhada(),
                atividade.getDuracaoEstimadaMinutos(),
                atividade.getTipo()
        );
    }
}