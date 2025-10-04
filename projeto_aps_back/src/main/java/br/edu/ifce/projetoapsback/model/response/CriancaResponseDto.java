package br.edu.ifce.projetoapsback.model.response;

import br.edu.ifce.projetoapsback.model.Crianca;
import br.edu.ifce.projetoapsback.model.dto.UserSummaryDto;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

public record CriancaResponseDto(
        Long id,
        String nomeCompleto,
        LocalDate dataNascimento,
        String diagnostico,
        String informacoesAdicionais,
        UserSummaryDto responsavel, // DTO resumido para não expor todos os dados do usuário
        List<UserSummaryDto> terapeutas
) {
    // Construtor de conveniência para mapear da entidade para o DTO
    public CriancaResponseDto(Crianca crianca) {
        this(
                crianca.getId(),
                crianca.getNomeCompleto(),
                crianca.getDataNascimento(),
                crianca.getDescricaoDiagnostico(),
                crianca.getInformacoesAdicionais(),
                new UserSummaryDto(crianca.getResponsavel()),
                crianca.getTerapeutas().stream().map(UserSummaryDto::new).collect(Collectors.toList())
        );
    }
}