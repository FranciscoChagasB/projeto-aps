package br.edu.ifce.projetoapsback.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

/**
 * SRP (Single Responsibility Principle):
 * A responsabilidade única desta classe é representar a criança que receberá o tratamento.
 * Ela armazena os dados demográficos e clínicos da criança, separando-a da entidade 'User',
 * que representa o operador do sistema (pai, terapeuta).
 */
@Table(name = "criancas")
@Entity(name = "Crianca")
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Getter
@Setter
public class Crianca {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    private String nomeCompleto;

    private LocalDate dataNascimento;

    private String informacoesAdicionais; // Alergias, preferências, observações importantes

    @Lob
    private String fotoCriancaBase64; // Base64 da foto da criança

    @Lob
    private String anexoDiagnosticoBase64; // Base64 do arquivo pdf do laudo da criança, se houver

    private String descricaoDiagnostico; // Ex: "Transtorno do Espectro Autista (TEA) - Nível 1"

    // Muitas crianças podem estar sob a responsabilidade de UM usuário (o pai/mãe).
    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    @JoinColumn(name = "responsavel_id")
    private User responsavel;

    // Uma criança pode ser acompanhada por vários terapeutas e um terapeuta pode acompanhar várias crianças.
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "terapeuta_acompanha_crianca",
            joinColumns = @JoinColumn(name = "crianca_id"),
            inverseJoinColumns = @JoinColumn(name = "terapeuta_id")
    )
    private List<User> terapeutas;

    private LocalDateTime dataCriacao;

    @PrePersist
    protected void onCreate() {
        dataCriacao = LocalDateTime.now();
    }
}