package br.edu.ifce.projetoapsback.model.dto;

import br.edu.ifce.projetoapsback.model.User;

public record UserSummaryDto(Integer id, String fullName, String email) {
    public UserSummaryDto(User user) {
        this(user.getId(), user.getFullName(), user.getEmail());
    }
}