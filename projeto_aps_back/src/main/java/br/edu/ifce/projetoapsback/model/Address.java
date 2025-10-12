package br.edu.ifce.projetoapsback.model;

import jakarta.persistence.Embeddable;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Embeddable
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Address {

    private String street;       // Ex: "Main Street"
    private String number;       // Ex: "123"
    private String complement;   // Ex: "Apt 4B" or "2nd Floor"
    private String neighborhood; // Ex: "Downtown"
    private String city;         // Ex: "Fortaleza"
    private String state;        // Ex: "CE"
    private String postalCode;   // Ex: 60000000

}