package br.edu.ifce.projetoapsback.model.response;

import br.edu.ifce.projetoapsback.model.dto.Message;

import java.util.List;

public record OpenAiResponse(List<Choice> choices) {
    public record Choice(Message message) {}
}