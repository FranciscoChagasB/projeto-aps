package br.edu.ifce.projetoapsback.util.mapper;

import br.edu.ifce.projetoapsback.model.Crianca;
import br.edu.ifce.projetoapsback.model.dto.UserSummaryDto;
import br.edu.ifce.projetoapsback.model.request.CriancaRequestDto;
import br.edu.ifce.projetoapsback.model.response.CriancaResponseDto;
import org.springframework.stereotype.Component;

import java.util.Collections;
import java.util.Optional;
import java.util.stream.Collectors;

@Component
public class CriancaMapper {

    public CriancaResponseDto toResponseDto(Crianca crianca) {
        return new CriancaResponseDto(
                crianca.getId(),
                crianca.getNomeCompleto(),
                crianca.getDataNascimento(),
                crianca.getAnexoDiagnosticoBase64(),
                crianca.getDescricaoDiagnostico(),
                crianca.getInformacoesAdicionais(),
                crianca.getFotoCriancaBase64(),
                new UserSummaryDto(crianca.getResponsavel()),
                Optional.ofNullable(crianca.getTerapeutas())
                        .orElse(Collections.emptyList()) // Se terapeutas for nulo, usa uma lista vazia
                        .stream()
                        .map(UserSummaryDto::new)
                        .collect(Collectors.toList())
        );
    }

    public Crianca toEntity(CriancaRequestDto dto) {
        return Crianca.builder()
                .nomeCompleto(dto.nomeCompleto())
                .dataNascimento(dto.dataNascimento())
                .anexoDiagnosticoBase64(dto.anexoDiagnostico())
                .descricaoDiagnostico(dto.descricaoDiagnostico())
                .informacoesAdicionais(dto.informacoesAdicionais())
                .fotoCriancaBase64(dto.fotoCrianca())
                .build();
    }

    public void updateEntityFromDto(CriancaRequestDto dto, Crianca crianca) {
        crianca.setNomeCompleto(dto.nomeCompleto());
        crianca.setDataNascimento(dto.dataNascimento());
        crianca.setAnexoDiagnosticoBase64(dto.anexoDiagnostico());
        crianca.setDescricaoDiagnostico(dto.descricaoDiagnostico());
        crianca.setInformacoesAdicionais(dto.informacoesAdicionais());
        crianca.setFotoCriancaBase64(dto.fotoCrianca());
    }
}