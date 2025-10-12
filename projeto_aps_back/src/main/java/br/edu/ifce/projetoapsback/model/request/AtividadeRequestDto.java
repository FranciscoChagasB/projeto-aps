package br.edu.ifce.projetoapsback.model.request;

import br.edu.ifce.projetoapsback.model.PlanoDeAtividade;
import br.edu.ifce.projetoapsback.model.enumeration.TipoAtividade;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.util.List;

public record AtividadeRequestDto(
        @NotBlank(message = "O título da atividade é obrigatório")
        String titulo,

        @NotBlank(message = "A descrição detalhada é obrigatória")
        String descricaoDetalhada,

        @NotNull(message = "A duração estimada é obrigatória")
        @Min(value = 1, message = "A duração deve ser de no mínimo 1 minuto")
        Integer duracaoEstimadaMinutos,

        @NotNull(message = "O tipo da atividade é obrigatório")
        TipoAtividade tipo,

        List<PlanoDeAtividade>planos
) {}