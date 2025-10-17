package br.edu.ifce.projetoapsback.service;

import br.edu.ifce.projetoapsback.config.SecurityConfiguration;
import br.edu.ifce.projetoapsback.model.Role;
import br.edu.ifce.projetoapsback.model.User;
import br.edu.ifce.projetoapsback.model.enumeration.RoleName;
import br.edu.ifce.projetoapsback.model.request.UserRequestDto;
import br.edu.ifce.projetoapsback.model.response.UserAdminResponseDto;
import br.edu.ifce.projetoapsback.repository.RoleRepository;
import br.edu.ifce.projetoapsback.repository.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AdminService {

    private final UserRepository userRepository;

    private final RoleRepository roleRepository;

    private final SecurityConfiguration securityConfiguration;

    @Value("${DEFAULT_PASSWORD}")
    private String defaultPassword;

    @Transactional
    public User createUser(UserRequestDto userRequestDto) {
        // Cria um novo usuário com os dados fornecidos
        User newUser = User.builder()
                .email(userRequestDto.email())
                .password(securityConfiguration.passwordEncoder().encode(defaultPassword))
                .fullName(userRequestDto.fullName())
                .cpf(userRequestDto.cpf())
                .phone(userRequestDto.phone())
                .address(userRequestDto.address())
                .active(userRequestDto.active())
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .roles(List.of(Role.builder().name(userRequestDto.role()).build()))
                .build();

        if (userRequestDto.role() == RoleName.HEALTH_PROFESSIONAL){
            newUser.setProfessionalCode(UUID.randomUUID().toString());
        }

        // Salva o novo usuário no banco de dados
        return userRepository.save(newUser);
    }

    @Transactional(readOnly = true)
    public List<User> getAll(String email, String cpf, String fullName, Boolean active, String professionalCode) {
        return userRepository.findAllWithFilters(email, cpf, fullName, active, professionalCode);
    }

    @Transactional(readOnly = true)
    public User getById(Integer id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Usuário não encontrado com ID: " + id));
    }

    @Transactional
    public User update(Integer id, UserRequestDto updatedUser) {
        User existingUser = userRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Usuário não encontrado com ID: " + id));

        existingUser.setFullName(updatedUser.fullName());
        existingUser.setEmail(updatedUser.email());
        existingUser.setCpf(updatedUser.cpf());
        existingUser.setPhone(updatedUser.phone());
        existingUser.setAddress(updatedUser.address());
        existingUser.setActive(updatedUser.active());

        if (updatedUser.role() != null) {
            Role newRole = roleRepository.findByName(updatedUser.role())
                    .orElseThrow(() -> new RuntimeException("Role não encontrada: " + updatedUser.role()));
            // Usa uma lista mutável (ArrayList)
            existingUser.setRoles(new ArrayList<>(Collections.singletonList(newRole)));
        }

        if (updatedUser.role() == RoleName.HEALTH_PROFESSIONAL && existingUser.getProfessionalCode() == null) {
            // Gera o código apenas se o usuário for um profissional e ainda não tiver um
            existingUser.setProfessionalCode(UUID.randomUUID().toString());
        }

        return userRepository.save(existingUser);
    }

    @Transactional
    public void delete(Integer id) {
        User existingUser = userRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Usuário não encontrado com ID: " + id));
        userRepository.deleteById(id);
    }
}