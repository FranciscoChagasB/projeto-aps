package br.edu.ifce.projetoapsback.repository;

import br.edu.ifce.projetoapsback.model.PlanoDeAtividade;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PlanoDeAtividadeRepository extends JpaRepository<PlanoDeAtividade, Integer> {

    List<PlanoDeAtividade> findByCriancaId(Integer criancaId);

}
