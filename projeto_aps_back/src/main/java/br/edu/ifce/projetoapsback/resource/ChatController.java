package br.edu.ifce.projetoapsback.resource;

import br.edu.ifce.projetoapsback.model.request.ChatMessageRequestDto;
import br.edu.ifce.projetoapsback.model.response.ChatMessageResponseDto;
import br.edu.ifce.projetoapsback.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/chat")
@RequiredArgsConstructor
public class ChatController {

    private final ChatService chatService;

    @PostMapping
    @PreAuthorize("hasAuthority('PARENT') or hasAuthority('HEALTH_PROFESSIONAL')")
    public ResponseEntity<ChatMessageResponseDto> sendMessage(
            @RequestBody ChatMessageRequestDto dto,
            Authentication authentication) {
        return ResponseEntity.ok(chatService.sendMessage(dto, authentication.getName()));
    }

    @GetMapping("/{criancaId}")
    @PreAuthorize("hasAuthority('PARENT') or hasAuthority('HEALTH_PROFESSIONAL')")
    public ResponseEntity<List<ChatMessageResponseDto>> getMessages(
            @PathVariable Integer criancaId,
            Authentication authentication) {
        return ResponseEntity.ok(chatService.getMessages(criancaId, authentication.getName()));
    }
}