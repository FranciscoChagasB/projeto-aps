package br.edu.ifce.projetoapsback.repository;

import br.edu.ifce.projetoapsback.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Integer> {

    Optional<User> findByEmail(String email);
    Optional<User> findByProfessionalCode(String professionalCode);
    @Query("""
        SELECT u FROM User u
        WHERE (:email IS NULL OR LOWER(u.email) LIKE LOWER(CONCAT('%', :email, '%')))
        AND (:cpf IS NULL OR LOWER(u.cpf) LIKE LOWER(CONCAT('%', :cpf, '%')))
        AND (:fullName IS NULL OR LOWER(u.fullName) LIKE LOWER(CONCAT('%', :fullName, '%')))
        AND (:active IS NULL OR u.active = :active)
        ORDER BY u.fullName DESC
        """)
    List<User> findAllWithFilters(
            @Param("email") String email,
            @Param("cpf") String cpf,
            @Param("fullName") String fullName,
            @Param("active") Boolean active,
            @Param("professionalCode") String professionalCode
    );
}
