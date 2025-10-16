package br.edu.ifce.projetoapsback.model.request;

import jakarta.validation.constraints.NotBlank;

public record PlanoUpdateRequestDto(
        @NotBlank String nome,
        @NotBlank String objetivo
) {}