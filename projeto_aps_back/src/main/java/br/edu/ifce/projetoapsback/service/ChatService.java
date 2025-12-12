package br.edu.ifce.projetoapsback.service;

import br.edu.ifce.projetoapsback.model.ChatMessage;
import br.edu.ifce.projetoapsback.model.Crianca;
import br.edu.ifce.projetoapsback.model.User;
import br.edu.ifce.projetoapsback.model.request.ChatMessageRequestDto;
import br.edu.ifce.projetoapsback.model.response.ChatMessageResponseDto;
import br.edu.ifce.projetoapsback.repository.ChatMessageRepository;
import br.edu.ifce.projetoapsback.repository.CriancaRepository;
import br.edu.ifce.projetoapsback.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ChatService {

    private final ChatMessageRepository chatRepository;
    private final UserRepository userRepository;
    private final CriancaRepository criancaRepository;

    public ChatMessageResponseDto sendMessage(ChatMessageRequestDto dto, String senderEmail) {
        User sender = userRepository.findByEmail(senderEmail)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));

        Crianca crianca = criancaRepository.findById(dto.criancaId())
                .orElseThrow(() -> new RuntimeException("Criança não encontrada"));

        // Define o destinatário
        User recipient = null;

        if (crianca.getResponsavel().getId().equals(sender.getId())) {
            if (!crianca.getTerapeutas().isEmpty()) {
                recipient = crianca.getTerapeutas().get(0);
            }
        } else {
            recipient = crianca.getResponsavel();
        }

        ChatMessage message = new ChatMessage();
        message.setSender(sender);
        message.setRecipient(recipient);
        message.setCrianca(crianca);
        message.setContent(dto.content());
        message.setRead(false);

        ChatMessage saved = chatRepository.save(message);

        return new ChatMessageResponseDto(
                saved.getId(),
                saved.getSender().getFullName(),
                saved.getSender().getEmail(),
                saved.getContent(),
                saved.getTimestamp(),
                true // Como acabou de enviar, é dele mesmo
        );
    }

    public List<ChatMessageResponseDto> getMessages(Integer criancaId, String currentUserEmail) {
        User currentUser = userRepository.findByEmail(currentUserEmail)
                .orElseThrow(() -> new RuntimeException("Usuário atual não encontrado"));

        Crianca crianca = criancaRepository.findById(criancaId)
                .orElseThrow(() -> new RuntimeException("Criança não encontrada"));

        validarPermissaoChat(currentUser, crianca);

        markMessagesAsRead(criancaId, currentUserEmail);

        return chatRepository.findByCriancaIdOrderByTimestampAsc(Long.valueOf(criancaId))
                .stream()
                .map(msg -> new ChatMessageResponseDto(
                        msg.getId(),
                        msg.getSender().getFullName(),
                        msg.getSender().getEmail(),
                        msg.getContent(),
                        msg.getTimestamp(),
                        msg.getSender().getEmail().equals(currentUserEmail)
                ))
                .toList();
    }

    public void markMessagesAsRead(Integer criancaId, String userEmail) {
        // Busca mensagens enviadas PARA MIM, nesta criança, que não foram lidas
        List<ChatMessage> unreadMessages = chatRepository.findByCriancaIdOrderByTimestampAsc(Long.valueOf(criancaId)).stream()
                .filter(m -> !m.isRead() && m.getRecipient() != null && m.getRecipient().getEmail().equals(userEmail))
                .toList();

        for (ChatMessage msg : unreadMessages) {
            msg.setRead(true);
        }
        chatRepository.saveAll(unreadMessages);
    }

    private void validarPermissaoChat(User usuario, Crianca crianca) {
        // Verifica se é o Pai/Responsável e Terapeuta
        boolean eResponsavel = crianca.getResponsavel().getId().equals(usuario.getId());

        boolean eTerapeutaVinculado = crianca.getTerapeutas().stream()
                .anyMatch(terapeuta -> terapeuta.getId().equals(usuario.getId()));

        if (!eResponsavel && !eTerapeutaVinculado) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN,
                    "Acesso negado: Você não tem permissão para acessar o chat desta criança.");
        }
    }
}