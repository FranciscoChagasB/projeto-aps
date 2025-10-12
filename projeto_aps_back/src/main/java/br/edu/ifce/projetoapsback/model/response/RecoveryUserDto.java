package br.edu.ifce.projetoapsback.model.response;

import br.edu.ifce.projetoapsback.model.Role;

import java.time.LocalDateTime;
import java.util.List;

public record RecoveryUserDto (
    Integer id,
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
    List<Role> roles,
    String professionalCode
) {

}
