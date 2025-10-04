package br.edu.ifce.projetoapsback.model.request;

public record LoginRequestDto(
    String email,
    String password
) {
}