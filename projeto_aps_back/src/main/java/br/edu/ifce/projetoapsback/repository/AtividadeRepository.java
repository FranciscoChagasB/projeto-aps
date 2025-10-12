package br.edu.ifce.projetoapsback.repository;

import br.edu.ifce.projetoapsback.model.Atividade;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface AtividadeRepository extends JpaRepository<Atividade, Integer> {

    Optional<Atividade> findById(Integer atividadeId);

}
