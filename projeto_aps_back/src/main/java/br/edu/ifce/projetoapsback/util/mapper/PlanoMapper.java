package br.edu.ifce.projetoapsback.util.mapper;

import br.edu.ifce.projetoapsback.model.PlanoDeAtividade;
import br.edu.ifce.projetoapsback.model.dto.*;
import br.edu.ifce.projetoapsback.model.request.PlanoRequestDto;
import br.edu.ifce.projetoapsback.model.response.PlanoResponseDto;
import org.springframework.stereotype.Component;
import java.util.stream.Collectors;

@Component
public class PlanoMapper {

    public PlanoResponseDto toResponseDto(PlanoDeAtividade plano) {
        return new PlanoResponseDto(
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

    // O toEntity é um pouco mais simples pois as entidades relacionadas são buscadas e setadas no Service
    public PlanoDeAtividade toEntity(PlanoRequestDto dto) {
        return PlanoDeAtividade.builder()
                .nome(dto.nome())
                .objetivo(dto.objetivo())
                .build();
    }
}