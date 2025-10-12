package br.edu.ifce.projetoapsback.repository;

import br.edu.ifce.projetoapsback.model.Crianca;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CriancaRepository extends JpaRepository<Crianca, Integer> {

    List<Crianca> findByResponsavelId(Integer responsavelId);
    List<Crianca> findByTerapeutasId(Integer terapeutaId);

}
