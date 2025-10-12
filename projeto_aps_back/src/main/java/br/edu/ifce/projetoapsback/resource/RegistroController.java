package br.edu.ifce.projetoapsback.resource;

import br.edu.ifce.projetoapsback.model.request.RegistroRequestDto;
import br.edu.ifce.projetoapsback.model.response.RegistroResponseDto;
import br.edu.ifce.projetoapsback.service.RegistroService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/registros")
@RequiredArgsConstructor
public class RegistroController {

    private final RegistroService registroService;

    @PostMapping
    @PreAuthorize("hasRole('PARENT')")
    public ResponseEntity<RegistroResponseDto> createRegistro(@Valid @RequestBody RegistroRequestDto requestDto) {
        RegistroResponseDto novoRegistro = registroService.create(requestDto);
        return new ResponseEntity<>(novoRegistro, HttpStatus.CREATED);
    }

    @GetMapping("/plano/{planoId}")
    public ResponseEntity<List<RegistroResponseDto>> getRegistrosByPlano(@PathVariable Integer planoId) {
        return ResponseEntity.ok(registroService.findByPlanoId(planoId));
    }

    // Endpoint específico para o terapeuta adicionar feedback a um registro existente
    @PatchMapping("/{registroId}/feedback")
    @PreAuthorize("hasRole('HEALTH_PROFESSIONAL')")
    public ResponseEntity<RegistroResponseDto> addFeedback(
            @PathVariable Integer registroId,
            @RequestBody String feedback) {
        return ResponseEntity.ok(registroService.addFeedback(registroId, feedback));
    }

    @PatchMapping("/{registroId}/observacoes")
    @PreAuthorize("hasRole('PARENT')")
    public ResponseEntity<RegistroResponseDto> updateObservacoes(
            @PathVariable Integer registroId,
            @RequestBody String observacoes) {
        return ResponseEntity.ok(registroService.updateObservacoes(registroId, observacoes));
    }

}
