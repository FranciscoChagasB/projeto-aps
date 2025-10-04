package br.edu.ifce.projetoapsback.model.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import java.util.List;

public record PlanoRequestDto(
        @NotBlank(message = "O nome do plano é obrigatório")
        String nome,

        @NotBlank(message = "O objetivo do plano é obrigatório")
        String objetivo,

        @NotNull(message = "O ID da criança é obrigatório")
        Long criancaId,

        @NotEmpty(message = "O plano deve conter ao menos uma atividade")
        List<Long> atividadeIds
) {}