package br.edu.ifce.projetoapsback.config;

import br.edu.ifce.projetoapsback.security.UserAuthenticationFilter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
public class SecurityConfiguration {

    public static final String [] ENDPOINTS_WITH_AUTHENTICATION_NOT_REQUIRED = {
            "/users/login", //url para fazer login
            "/users", //url para criar um usuário
    };

    // Endpoints que requerem autenticação para serem acessados
    public static final String [] ENDPOINTS_WITH_AUTHENTICATION_REQUIRED = {
            "/users/test"
    };

    // Endpoints que só podem ser acessados por usuários com permissão de Profissional de Saúde
    public static final String [] ENDPOINTS_HEALTH_PROFESSIONAL = {
            "/users/test/health" // Exemplo de novo endpoint
    };

    // Endpoints que só podem ser acessados por usuários com permissão de Administrador
    public static final String [] ENDPOINTS_ADMINISTRATOR = {
            "/users/test/administrator",
            "/admin/**"
    };

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity httpSecurity, UserAuthenticationFilter userAuthenticationFilter) throws Exception {
        return httpSecurity
                .csrf(csrf -> csrf.disable())
                .cors(cors -> {}) // aqui ele já vai puxar o CorsConfigurationSource do @Bean
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers(ENDPOINTS_WITH_AUTHENTICATION_NOT_REQUIRED).permitAll()
                        .requestMatchers(ENDPOINTS_ADMINISTRATOR).hasAuthority("ADMINISTRATOR")
                        .requestMatchers(ENDPOINTS_HEALTH_PROFESSIONAL).hasAuthority("HEALTH_PROFESSIONAL")
                        .anyRequest().authenticated()
                )
                .addFilterBefore(userAuthenticationFilter, UsernamePasswordAuthenticationFilter.class)
                .build();
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration authenticationConfiguration) throws Exception {
        return authenticationConfiguration.getAuthenticationManager();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

}
