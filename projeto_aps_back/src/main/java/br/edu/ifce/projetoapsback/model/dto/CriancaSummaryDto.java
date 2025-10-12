package br.edu.ifce.projetoapsback.model.dto;

import br.edu.ifce.projetoapsback.model.Crianca;

public record CriancaSummaryDto(Integer id, String nomeCompleto) {
    public CriancaSummaryDto(Crianca crianca) {
        this(crianca.getId(), crianca.getNomeCompleto());
    }
}