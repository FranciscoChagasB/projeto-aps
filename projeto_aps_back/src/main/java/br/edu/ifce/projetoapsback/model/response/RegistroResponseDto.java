package br.edu.ifce.projetoapsback.model.response;

import br.edu.ifce.projetoapsback.model.RegistroDeAtividade;
import br.edu.ifce.projetoapsback.model.dto.AtividadeSummaryDto;
import br.edu.ifce.projetoapsback.model.dto.CriancaSummaryDto;
import br.edu.ifce.projetoapsback.model.enumeration.StatusRegistro;
import java.time.LocalDateTime;

public record RegistroResponseDto(
        Long id,
        AtividadeSummaryDto atividade,
        CriancaSummaryDto crianca,
        LocalDateTime dataHoraConclusao,
        String observacoesDoResponsavel,
        String feedbackDoTerapeuta,
        StatusRegistro status
) {
    public RegistroResponseDto(RegistroDeAtividade registro) {
        this(
                registro.getId(),
                new AtividadeSummaryDto(registro.getAtividade()),
                new CriancaSummaryDto(registro.getCrianca()),
                registro.getDataHoraConclusao(),
                registro.getObservacoesDoResponsavel(),
                registro.getFeedbackDoTerapeuta(),
                registro.getStatus()
        );
    }
}