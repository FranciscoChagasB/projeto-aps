package br.edu.ifce.projetoapsback.model.request;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;

@Getter
public class UpdateUserStatusRequestDto {
    @NotNull(message = "O status 'active' não pode ser nulo")
    private Boolean active;
}