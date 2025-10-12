package br.edu.ifce.projetoapsback.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.List;

/**
 * SRP (Single Responsibility Principle):
 * A responsabilidade única desta classe é representar um Plano de Atividades.
 * Ela contém apenas os dados que definem um plano (nome, objetivo, quem criou, para quem é, etc.),
 * sem se preocupar com a lógica de execução ou relatórios.
 */
@Table(name = "planos_atividade")
@Entity(name = "PlanoDeAtividade")
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Getter
@Setter
public class PlanoDeAtividade {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    private String nome;
    private String objetivo;

    @ManyToOne
    @JoinColumn(name = "terapeuta_id", nullable = false)
    private User terapeuta;

    // ALTERADO AQUI: O plano agora aponta para a criança, não para o usuário responsável.
    @ManyToOne(optional = false)
    @JoinColumn(name = "crianca_id")
    private Crianca crianca;

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "plano_possui_atividades",
            joinColumns = @JoinColumn(name = "plano_id"),
            inverseJoinColumns = @JoinColumn(name = "atividade_id")
    )
    private List<Atividade> atividades;

    private LocalDateTime dataCriacao;
    private LocalDateTime dataAtualizacao;

    @PrePersist
    protected void onCreate() {
        dataCriacao = LocalDateTime.now();
        dataAtualizacao = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        dataAtualizacao = LocalDateTime.now();
    }
}