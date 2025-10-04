package br.edu.ifce.projetoapsback.model.request;

import br.edu.ifce.projetoapsback.model.Address;
import br.edu.ifce.projetoapsback.model.enumeration.RoleName;

import java.time.LocalDateTime;

public record UserRequestDto(
    String email,
    String password,
    String fullName,
    String cpf,
    String phone,
    Address address,
    Boolean active,
    LocalDateTime createdAt,
    LocalDateTime updatedAt,
    RoleName role
) {

}
