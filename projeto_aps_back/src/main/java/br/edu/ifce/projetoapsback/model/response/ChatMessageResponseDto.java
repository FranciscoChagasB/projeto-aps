package br.edu.ifce.projetoapsback.model.response;

import java.time.LocalDateTime;

public record ChatMessageResponseDto(
        Long id,
        String senderName,
        String senderEmail,
        String content,
        LocalDateTime timestamp,
        boolean isMine // Helper para o front saber se alinha a msg na direita ou esquerda
) {}