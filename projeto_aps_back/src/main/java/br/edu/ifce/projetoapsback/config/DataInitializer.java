package br.edu.ifce.projetoapsback.config;

import br.edu.ifce.projetoapsback.model.request.UserRequestDto;
import br.edu.ifce.projetoapsback.model.enumeration.RoleName;
import br.edu.ifce.projetoapsback.repository.UserRepository;
import br.edu.ifce.projetoapsback.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Configuration;

import java.time.LocalDateTime;

@Configuration
public class DataInitializer implements CommandLineRunner {

    @Autowired
    private UserService userService;

    @Autowired
    private UserRepository userRepository;

    @Override
    public void run(String... args) throws Exception {

        // 1. Cria o usuário ADMINISTRATOR se ele não existir
        if (userRepository.findByEmail("admin@email.com").isEmpty()) {
            UserRequestDto adminUser = new UserRequestDto(
                    "admin@email.com",
                    "123456", // A senha será codificada pelo seu serviço
                    "Administrador do Sistema",
                    "11111111111",
                    "85911111111",
                    null,
                    true,
                    LocalDateTime.now(),
                    null,
                    RoleName.ADMINISTRATOR
            );
            userService.createUser(adminUser);
            System.out.println("✅ Usuário ADMINISTRATOR criado com sucesso!");
        }

        // 2. Cria o usuário PARENT se ele não existir
        if (userRepository.findByEmail("parent@email.com").isEmpty()) {
            UserRequestDto parentUser = new UserRequestDto(
                    "parent@email.com",
                    "123456",
                    "Pai/Mãe Exemplo",
                    "22222222222",
                    "85922222222",
                    null,
                    true,
                    LocalDateTime.now(),
                    null,
                    RoleName.PARENT
            );
            userService.createUser(parentUser);
            System.out.println("✅ Usuário PARENT criado com sucesso!");
        }

        // 3. Cria o usuário HEALTH_PROFESSIONAL se ele não existir
        if (userRepository.findByEmail("health@email.com").isEmpty()) {
            UserRequestDto healthUser = new UserRequestDto(
                    "health@email.com",
                    "123456",
                    "Profissional de Saúde Exemplo",
                    "33333333333",
                    "85933333333",
                    null,
                    true,
                    LocalDateTime.now(),
                    null,
                    RoleName.HEALTH_PROFESSIONAL
            );
            userService.createUser(healthUser);
            System.out.println("✅ Usuário HEALTH_PROFESSIONAL criado com sucesso!");
        }
    }
}
