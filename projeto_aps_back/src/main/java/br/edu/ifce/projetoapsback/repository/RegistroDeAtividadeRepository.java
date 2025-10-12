package br.edu.ifce.projetoapsback.repository;

import br.edu.ifce.projetoapsback.model.RegistroDeAtividade;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RegistroDeAtividadeRepository extends JpaRepository<RegistroDeAtividade, Integer> {

    List<RegistroDeAtividade> findByPlanoId(Integer planoId);

}
