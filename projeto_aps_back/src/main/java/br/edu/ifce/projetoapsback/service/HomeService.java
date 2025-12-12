package br.edu.ifce.projetoapsback.service;

import br.edu.ifce.projetoapsback.model.ChatMessage;
import br.edu.ifce.projetoapsback.model.User;
import br.edu.ifce.projetoapsback.model.response.HomeInfoResponseDto;
import br.edu.ifce.projetoapsback.repository.ChatMessageRepository;
import br.edu.ifce.projetoapsback.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalTime;
import java.util.List;
import java.util.Random;

@Service
@RequiredArgsConstructor
public class HomeService {

    private final UserRepository userRepository;
    private final ChatMessageRepository chatMessageRepository;

    public HomeInfoResponseDto getHomeInfo(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        String greeting = getGreeting();
        String quote = getRandomQuote();
        Long unread = chatMessageRepository.countByRecipientEmailAndIsReadFalse(email);

        // --- LÓGICA DE NAVEGAÇÃO ---
        Integer lastCriancaId = null;
        String lastCriancaName = null;

        if (unread > 0) {
            // Busca a última mensagem para saber pra onde mandar o usuário
            ChatMessage lastMsg = chatMessageRepository.findFirstByRecipientEmailAndIsReadFalseOrderByTimestampDesc(email);
            if (lastMsg != null) {
                lastCriancaId = Math.toIntExact(lastMsg.getCrianca().getId());
                lastCriancaName = lastMsg.getCrianca().getNomeCompleto();
            }
        }

        return new HomeInfoResponseDto(greeting, quote, unread, lastCriancaId, lastCriancaName);
    }

    private String getGreeting() {
        int hour = LocalTime.now().getHour();
        if (hour >= 5 && hour < 12) return "Bom dia";
        if (hour >= 12 && hour < 18) return "Boa tarde";
        return "Boa noite";
    }

    private String getRandomQuote() {
        List<String> quotes = List.of(
                "Pequenos progressos são grandes vitórias.",
                "Cada passo conta na jornada do desenvolvimento.",
                "A persistência é o caminho do êxito.",
                "Celebre cada conquista, por menor que pareça.",
                "O carinho é a melhor ferramenta terapêutica."
        );
        return quotes.get(new Random().nextInt(quotes.size()));
    }
}