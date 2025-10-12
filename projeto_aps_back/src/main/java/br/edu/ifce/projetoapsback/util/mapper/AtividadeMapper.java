package br.edu.ifce.projetoapsback.util.mapper;

import br.edu.ifce.projetoapsback.model.Atividade;
import br.edu.ifce.projetoapsback.model.request.AtividadeRequestDto;
import br.edu.ifce.projetoapsback.model.response.AtividadeResponseDto;
import org.springframework.stereotype.Component;

@Component
public class AtividadeMapper {

    public AtividadeResponseDto toResponseDto(Atividade atividade) {
        return new AtividadeResponseDto(
                atividade.getId(),
                atividade.getTitulo(),
                atividade.getDescricaoDetalhada(),
                atividade.getDuracaoEstimadaMinutos(),
                atividade.getTipo(),
                atividade.getPlanos()
        );
    }

    public Atividade toEntity(AtividadeRequestDto dto) {
        return Atividade.builder()
                .titulo(dto.titulo())
                .descricaoDetalhada(dto.descricaoDetalhada())
                .duracaoEstimadaMinutos(dto.duracaoEstimadaMinutos())
                .tipo(dto.tipo())
                .planos(dto.planos())
                .build();
    }

    public void updateEntityFromDto(AtividadeRequestDto dto, Atividade atividade) {
        atividade.setTitulo(dto.titulo());
        atividade.setDescricaoDetalhada(dto.descricaoDetalhada());
        atividade.setDuracaoEstimadaMinutos(dto.duracaoEstimadaMinutos());
        atividade.setTipo(dto.tipo());
        atividade.setPlanos(dto.planos());
    }
}