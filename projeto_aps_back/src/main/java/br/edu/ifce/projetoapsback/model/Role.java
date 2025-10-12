package br.edu.ifce.projetoapsback.model;

import br.edu.ifce.projetoapsback.model.enumeration.RoleName;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name="roles")
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
public class Role {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Enumerated(EnumType.STRING)
    private RoleName name;

}
