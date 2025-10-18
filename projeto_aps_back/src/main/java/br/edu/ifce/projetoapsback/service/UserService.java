package br.edu.ifce.projetoapsback.service;

import br.edu.ifce.projetoapsback.config.SecurityConfiguration;
import br.edu.ifce.projetoapsback.model.Role;
import br.edu.ifce.projetoapsback.model.User;
import br.edu.ifce.projetoapsback.model.enumeration.RoleName;
import br.edu.ifce.projetoapsback.model.request.UserRequestDto;
import br.edu.ifce.projetoapsback.model.request.LoginRequestDto;
import br.edu.ifce.projetoapsback.model.response.RecoveryJwtTokenDto;
import br.edu.ifce.projetoapsback.repository.UserRepository;
import br.edu.ifce.projetoapsback.security.UserDetailsImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.UUID;

@Service
public class UserService {

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private JwtTokenService jwtTokenService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private SecurityConfiguration securityConfiguration;

    // Método responsável por autenticar um usuário e retornar um token JWT
    public RecoveryJwtTokenDto authenticateUser(LoginRequestDto loginRequestDto) {
        try {
            // Cria um objeto de autenticação com o email e a senha do usuário
            UsernamePasswordAuthenticationToken usernamePasswordAuthenticationToken =
                    new UsernamePasswordAuthenticationToken(loginRequestDto.email(), loginRequestDto.password());

            // Autentica o usuário com as credenciais fornecidas
            Authentication authentication = authenticationManager.authenticate(usernamePasswordAuthenticationToken);

            // Obtém o objeto UserDetails do usuário autenticado
            UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();

            // Gera um token JWT para o usuário autenticado
            return new RecoveryJwtTokenDto(jwtTokenService.generateToken(userDetails));
        }catch (Exception e) {
            throw new RuntimeException("Credenciais Inválidas: " + e.getMessage());
        }
    }

    // Método responsável por criar um usuário
    public void createUser(UserRequestDto userRequestDto) {
        try {
            if (userRequestDto.role() == RoleName.ADMINISTRATOR) {
                throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Você não tem permissão para criar administradores!");
            }

            // Cria um novo usuário com os dados fornecidos
            User newUser = User.builder()
                    .email(userRequestDto.email())
                    .password(securityConfiguration.passwordEncoder().encode(userRequestDto.password()))
                    .fullName(userRequestDto.fullName())
                    .cpf(userRequestDto.cpf())
                    .phone(userRequestDto.phone())
                    .address(userRequestDto.address())
                    .active(userRequestDto.active())
                    .createdAt(userRequestDto.createdAt())
                    .updatedAt(userRequestDto.updatedAt())
                    .roles(List.of(Role.builder().name(userRequestDto.role()).build()))
                    .build();

            if (userRequestDto.role() == RoleName.HEALTH_PROFESSIONAL) {
                newUser.setProfessionalCode(UUID.randomUUID().toString());
            }

            // Salva o novo usuário no banco de dados
            userRepository.save(newUser);
        }catch (Exception e) {
            throw new RuntimeException("Erro ao Criar Usuário " + e.getMessage());
        }
    }

}
