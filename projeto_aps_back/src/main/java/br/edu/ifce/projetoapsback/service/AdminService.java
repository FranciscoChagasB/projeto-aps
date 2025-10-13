package br.edu.ifce.projetoapsback.service;

import br.edu.ifce.projetoapsback.model.User;
import br.edu.ifce.projetoapsback.model.response.UserAdminResponseDto;
import br.edu.ifce.projetoapsback.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AdminService {

    private final UserRepository userRepository;

    public List<UserAdminResponseDto> getAllUsers() {
        return userRepository.findAll().stream()
                .map(UserAdminResponseDto::new)
                .collect(Collectors.toList());
    }

    public UserAdminResponseDto updateUserStatus(Integer userId, boolean active) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuário não encontrado"));

        user.setActive(active);
        User updatedUser = userRepository.save(user);
        return new UserAdminResponseDto(updatedUser);
    }
}