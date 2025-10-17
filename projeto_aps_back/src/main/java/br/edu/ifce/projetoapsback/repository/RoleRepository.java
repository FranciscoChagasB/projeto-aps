package br.edu.ifce.projetoapsback.repository;

import br.edu.ifce.projetoapsback.model.Role;
import br.edu.ifce.projetoapsback.model.enumeration.RoleName;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface RoleRepository extends JpaRepository<Role, Integer> {

    Optional<Role> findByName(RoleName name);

}
