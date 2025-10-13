package br.edu.ifce.projetoapsback.model.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Past;
import java.time.LocalDate;
import java.util.List;

public record CriancaRequestDto(
        @NotBlank(message = "O nome completo é obrigatório")
        String nomeCompleto,

        @NotNull(message = "A data de nascimento é obrigatória")
        @Past(message = "A data de nascimento deve ser no passado")
        LocalDate dataNascimento,

        String anexoDiagnostico,

        String descricaoDiagnostico,

        String informacoesAdicionais,

        String fotoCrianca,

        List<Integer> terapeutaIds
) {}