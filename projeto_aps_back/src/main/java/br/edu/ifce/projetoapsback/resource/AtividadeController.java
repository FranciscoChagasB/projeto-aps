package br.edu.ifce.projetoapsback.resource;

import br.edu.ifce.projetoapsback.model.request.AtividadeRequestDto;
import br.edu.ifce.projetoapsback.model.response.AtividadeResponseDto;
import br.edu.ifce.projetoapsback.service.AtividadeService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/atividades")
@RequiredArgsConstructor
public class AtividadeController {

    private final AtividadeService atividadeService;

    @PostMapping
    @PreAuthorize("hasRole('HEALTH_PROFESSIONAL')")
    public ResponseEntity<AtividadeResponseDto> createAtividade(@Valid @RequestBody AtividadeRequestDto requestDto) {
        AtividadeResponseDto novaAtividade = atividadeService.create(requestDto);
        return new ResponseEntity<>(novaAtividade, HttpStatus.CREATED);
    }

    @GetMapping
    public ResponseEntity<List<AtividadeResponseDto>> getAllAtividades() {
        return ResponseEntity.ok(atividadeService.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<AtividadeResponseDto> getAtividadeById(@PathVariable Integer id) {
        return ResponseEntity.ok(atividadeService.findById(id));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('HEALTH_PROFESSIONAL')")
    public ResponseEntity<AtividadeResponseDto> updateAtividade(@PathVariable Integer id, @Valid @RequestBody AtividadeRequestDto requestDto) {
        return ResponseEntity.ok(atividadeService.update(id, requestDto));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('HEALTH_PROFESSIONAL')")
    public ResponseEntity<Void> deleteAtividade(@PathVariable Integer id) {
        atividadeService.delete(id);
        return ResponseEntity.noContent().build();
    }

}
