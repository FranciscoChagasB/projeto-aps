package br.edu.ifce.projetoapsback.model.request;

import br.edu.ifce.projetoapsback.model.dto.Message;

import java.util.List;

public record OpenAiRequest(String model, List<Message> messages) {}