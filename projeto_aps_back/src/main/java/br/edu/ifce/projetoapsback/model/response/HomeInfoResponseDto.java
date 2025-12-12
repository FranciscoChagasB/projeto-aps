package br.edu.ifce.projetoapsback.model.response;

public record HomeInfoResponseDto(
    String greeting,       // "Bom dia", "Boa tarde"
    String quote,          // Frase motivacional
    Long unreadMessages,    // Número de mensagens não lidas no chat
    Integer lastMessageCriancaId,
    String lastMessageCriancaName
) {}