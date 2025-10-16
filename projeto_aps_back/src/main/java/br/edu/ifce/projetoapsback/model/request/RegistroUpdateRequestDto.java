package br.edu.ifce.projetoapsback.model.request;

import br.edu.ifce.projetoapsback.model.enumeration.StatusRegistro;
import jakarta.validation.constraints.NotNull;

public record RegistroUpdateRequestDto(
        @NotNull StatusRegistro status,
        String observacoesDoResponsavel
) {}