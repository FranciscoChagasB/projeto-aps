package br.edu.ifce.projetoapsback.model.dto;

import jakarta.validation.constraints.NotBlank;

public record LinkTerapeutaRequestDto(
        @NotBlank(message = "O código do profissional é obrigatório")
        String professionalCode
) {}