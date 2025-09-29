package br.edu.ifce.projetoapsback.model.dto;

import br.edu.ifce.projetoapsback.model.enumeration.RoleName;

import java.time.LocalDateTime;

public record CreateUserDto(
    String email,
    String password,
    String fullName,
    String cpf,
    String phone,
    String address,
    String city,
    String state,
    Boolean active,
    LocalDateTime createdAt,
    LocalDateTime updatedAt,
    RoleName role
) {

}
