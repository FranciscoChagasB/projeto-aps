package br.edu.ifce.projetoapsback.model.request;

public record ChatMessageRequestDto(
        Integer criancaId,
        String content
) {}