package br.edu.ifce.projetoapsback.model;

import br.edu.ifce.projetoapsback.model.enumeration.StatusRegistro;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

/**
 * SRP (Single Responsibility Principle):
 * A responsabilidade única desta classe é registrar a execução de uma atividade.
 * Ela responde às perguntas: "Quem fez?", "O que fez?", "Quando fez?" e "Como foi?".
 * Ela não define o que é a atividade, apenas registra sua ocorrência.
 */
@Table(name = "registros_atividades")
@Entity(name = "RegistroDeAtividade")
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Getter
@Setter
public class RegistroDeAtividade {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    // Relacionamento: Muitos registros pertencem a UMA atividade.
    @ManyToOne(optional = false)
    @JoinColumn(name = "atividade_id")
    private Atividade atividade;

    // O registro é feito para a criança que executou a atividade.
    @ManyToOne(optional = false)
    @JoinColumn(name = "crianca_id")
    private Crianca crianca; // <-- MUDANÇA CRUCIAL

    // Relacionamento direto com o plano para facilitar consultas de progresso de um plano específico
    @ManyToOne(optional = false)
    @JoinColumn(name = "plano_id")
    private PlanoDeAtividade plano;

    @Column(nullable = false)
    private LocalDateTime dataHoraConclusao;

    private String observacoesDoResponsavel; // Nome mais claro

    private String feedbackDoTerapeuta; // Feedback posterior do profissional

    /**
     * OCP (Open/Closed Principle):
     * O status da atividade é um Enum. Se no futuro precisarmos de novos status
     * (ex: 'PENDENTE_REVISAO'), podemos adicioná-los ao Enum sem alterar esta classe.
     */
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private StatusRegistro status;

    private LocalDateTime dataCriacao;

    @PrePersist
    protected void onCreate() {
        dataCriacao = LocalDateTime.now();
    }
}

