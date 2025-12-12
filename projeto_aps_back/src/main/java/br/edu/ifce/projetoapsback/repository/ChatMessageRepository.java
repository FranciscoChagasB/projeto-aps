package br.edu.ifce.projetoapsback.repository;

import br.edu.ifce.projetoapsback.model.ChatMessage;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ChatMessageRepository extends JpaRepository<ChatMessage, Long> {
    // Busca mensagens de uma criança ordenadas por data
    List<ChatMessage> findByCriancaIdOrderByTimestampAsc(Long criancaId);

    Long countByRecipientEmailAndIsReadFalse(String recipientEmail);

    ChatMessage findFirstByRecipientEmailAndIsReadFalseOrderByTimestampDesc(String recipientEmail);
}