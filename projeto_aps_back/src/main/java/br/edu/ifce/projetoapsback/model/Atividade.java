package br.edu.ifce.projetoapsback.model;

import br.edu.ifce.projetoapsback.model.enumeration.TipoAtividade;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.List;

/**
 * SRP (Single Responsibility Principle):
 * A responsabilidade única desta classe é representar uma Atividade.
 * Ela descreve O QUE é a atividade (título, descrição, tipo), mas não se preocupa
 * com QUANDO ou COMO ela foi executada. Essa responsabilidade é do 'RegistroDeAtividade'.
 */
@Table(name = "atividades")
@Entity(name = "Atividade")
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Getter
@Setter
public class Atividade {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    private String titulo;

    private String descricaoDetalhada;

    private Integer duracaoEstimadaMinutos;

    /**
     * OCP (Open/Closed Principle):
     * Usar um Enum para o tipo da atividade permite que no futuro novas categorias
     * sejam adicionadas (ex: COGNITIVA, MOTORA, SOCIAL) sem precisar modificar esta classe.
     * O sistema fica aberto para extensão, mas fechado para modificação.
     */
    @Enumerated(EnumType.STRING)
    private TipoAtividade tipo;

    // Mapeado pelo 'PlanoDeAtividades' para evitar redundância na definição do relacionamento.
    @ManyToMany(mappedBy = "atividades")
    private List<PlanoDeAtividade> planos;

    private LocalDateTime dataCriacao;

    @PrePersist
    protected void onCreate() {
        dataCriacao = LocalDateTime.now();
    }
}