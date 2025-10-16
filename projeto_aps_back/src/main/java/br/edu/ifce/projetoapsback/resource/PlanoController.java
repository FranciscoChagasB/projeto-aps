package br.edu.ifce.projetoapsback.resource;

import br.edu.ifce.projetoapsback.model.request.PlanoRequestDto;
import br.edu.ifce.projetoapsback.model.request.PlanoUpdateRequestDto;
import br.edu.ifce.projetoapsback.model.response.PlanoResponseDto;
import br.edu.ifce.projetoapsback.service.PlanoService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/planos")
@RequiredArgsConstructor
public class PlanoController {

    private final PlanoService planoService;

    @PostMapping
    @PreAuthorize("hasRole('HEALTH_PROFESSIONAL')")
    public ResponseEntity<PlanoResponseDto> createPlano(@Valid @RequestBody PlanoRequestDto requestDto, Authentication authentication) {
        PlanoResponseDto novoPlano = planoService.create(requestDto, authentication.getName());
        return new ResponseEntity<>(novoPlano, HttpStatus.CREATED);
    }

    // Rota aninhada e muito útil para o front-end: buscar todos os planos de uma criança específica
    @GetMapping("/crianca/{criancaId}")
    public ResponseEntity<List<PlanoResponseDto>> getPlanosByCrianca(@PathVariable Integer criancaId) {
        return ResponseEntity.ok(planoService.findByCriancaId(criancaId));
    }

    @GetMapping("/{id}")
    public ResponseEntity<PlanoResponseDto> getPlanoById(@PathVariable Integer id) {
        return ResponseEntity.ok(planoService.findById(id));
    }

    @PatchMapping("/{planoId}/adicionar-atividades")
    @PreAuthorize("hasRole('HEALTH_PROFESSIONAL')")
    public ResponseEntity<PlanoResponseDto> addAtividadesAoPlano(
            @PathVariable Integer planoId,
            @RequestBody List<Integer> atividadeIds) {
        return ResponseEntity.ok(planoService.addAtividades(planoId, atividadeIds));
    }

    @PatchMapping("/{planoId}/remover-atividades")
    @PreAuthorize("hasRole('HEALTH_PROFESSIONAL')")
    public ResponseEntity<PlanoResponseDto> removeAtividadesDoPlano(
            @PathVariable Integer planoId,
            @RequestBody List<Long> atividadeIds) {
        return ResponseEntity.ok(planoService.removeAtividades(planoId, atividadeIds));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('HEALTH_PROFESSIONAL')")
    public ResponseEntity<Void> deletePlano(@PathVariable Integer id, Authentication authentication) {
        planoService.delete(id, authentication.getName());
        return ResponseEntity.noContent().build();
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('HEALTH_PROFESSIONAL')")
    public ResponseEntity<PlanoResponseDto> updatePlano(
            @PathVariable Integer id,
            @Valid @RequestBody PlanoUpdateRequestDto requestDto,
            Authentication authentication) {
        return ResponseEntity.ok(planoService.update(id, requestDto, authentication.getName()));
    }
}
