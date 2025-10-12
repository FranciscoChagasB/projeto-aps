package br.edu.ifce.projetoapsback.util.mapper;

import br.edu.ifce.projetoapsback.model.RegistroDeAtividade;
import br.edu.ifce.projetoapsback.model.dto.AtividadeSummaryDto;
import br.edu.ifce.projetoapsback.model.dto.CriancaSummaryDto;
import br.edu.ifce.projetoapsback.model.request.RegistroRequestDto;
import br.edu.ifce.projetoapsback.model.response.RegistroResponseDto;
import org.springframework.stereotype.Component;

@Component
public class RegistroMapper {

    public RegistroResponseDto toResponseDto(RegistroDeAtividade registro) {
        return new RegistroResponseDto(
                registro.getId(),
                new AtividadeSummaryDto(registro.getAtividade()),
                new CriancaSummaryDto(registro.getCrianca()),
                registro.getDataHoraConclusao(),
                registro.getObservacoesDoResponsavel(),
                registro.getFeedbackDoTerapeuta(),
                registro.getStatus()
        );
    }

    public RegistroDeAtividade toEntity(RegistroRequestDto dto) {
        return RegistroDeAtividade.builder()
                .dataHoraConclusao(dto.dataHoraConclusao())
                .observacoesDoResponsavel(dto.observacoesDoResponsavel())
                .status(dto.status())
                .build();
    }
}