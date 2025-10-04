package br.edu.ifce.projetoapsback.model.response;

import br.edu.ifce.projetoapsback.model.PlanoDeAtividades;
import br.edu.ifce.projetoapsback.model.dto.AtividadeSummaryDto;
import br.edu.ifce.projetoapsback.model.dto.CriancaSummaryDto;
import br.edu.ifce.projetoapsback.model.dto.UserSummaryDto;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

public record PlanoResponseDto(
        Long id,
        String nome,
        String objetivo,
        UserSummaryDto terapeuta,
        CriancaSummaryDto crianca,
        List<AtividadeSummaryDto> atividades,
        LocalDateTime dataCriacao,
        LocalDateTime dataAtualizacao
) {
    public PlanoResponseDto(PlanoDeAtividades plano) {
        this(
                plano.getId(),
                plano.getNome(),
                plano.getObjetivo(),
                new UserSummaryDto(plano.getTerapeuta()),
                new CriancaSummaryDto(plano.getCrianca()),
                plano.getAtividades().stream().map(AtividadeSummaryDto::new).collect(Collectors.toList()),
                plano.getDataCriacao(),
                plano.getDataAtualizacao()
        );
    }
}