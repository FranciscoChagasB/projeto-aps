package br.edu.ifce.projetoapsback.model.request;

import br.edu.ifce.projetoapsback.model.enumeration.StatusRegistro;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PastOrPresent;

import java.time.LocalDateTime;

public record RegistroRequestDto(
        @NotNull(message = "O ID da atividade é obrigatório")
        Long atividadeId,

        @NotNull(message = "O ID do plano é obrigatório")
        Long planoId,

        @NotNull(message = "O ID da criança é obrigatório")
        Long criancaId,

        @NotNull(message = "A data e hora de conclusão são obrigatórias")
        @PastOrPresent(message = "A data de conclusão não pode ser no futuro")
        LocalDateTime dataHoraConclusao,

        String observacoesDoResponsavel,

        @NotNull(message = "O status do registro é obrigatório")
        StatusRegistro status
) {}