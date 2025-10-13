package br.edu.ifce.projetoapsback.model.response;

import br.edu.ifce.projetoapsback.model.User;
import lombok.Getter;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Getter
public class UserAdminResponseDto {
    private final Integer id;
    private final String fullName;
    private final String email;
    private final Boolean active;
    private final LocalDateTime createdAt;
    private final List<String> roles;

    public UserAdminResponseDto(User user) {
        this.id = user.getId();
        this.fullName = user.getFullName();
        this.email = user.getEmail();
        this.active = user.getActive();
        this.createdAt = user.getCreatedAt();
        this.roles = user.getRoles().stream()
                .map(role -> role.getName().toString())
                .collect(Collectors.toList());
    }
}