package br.edu.ifce.projetoapsback.resource;

import br.edu.ifce.projetoapsback.model.dto.LinkTerapeutaRequestDto;
import br.edu.ifce.projetoapsback.model.request.CriancaRequestDto;
import br.edu.ifce.projetoapsback.model.response.CriancaResponseDto;
import br.edu.ifce.projetoapsback.service.CriancaService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/criancas")
@RequiredArgsConstructor
public class CriancaController {

    private final CriancaService criancaService;

    @PostMapping
    @PreAuthorize("hasRole('PARENT')")
    public ResponseEntity<CriancaResponseDto> createCrianca(@Valid @RequestBody CriancaRequestDto requestDto, Authentication authentication) {
        CriancaResponseDto novaCrianca = criancaService.create(requestDto, authentication.getName());
        return new ResponseEntity<>(novaCrianca, HttpStatus.CREATED);
    }

    // Endpoint para um pai/responsável ver seus próprios filhos cadastrados
    @GetMapping("/meus")
    @PreAuthorize("hasRole('PARENT')")
    public ResponseEntity<List<CriancaResponseDto>> getMinhasCriancas(Authentication authentication) {
        return ResponseEntity.ok(criancaService.findByResponsavel(authentication.getName()));
    }

    // Endpoint para um terapeuta ver as crianças que ele acompanha
    @GetMapping("/terapeuta")
    @PreAuthorize("hasRole('HEALTH_PROFESSIONAL')")
    public ResponseEntity<List<CriancaResponseDto>> getCriancasDoTerapeuta(Authentication authentication) {
        return ResponseEntity.ok(criancaService.findByTerapeuta(authentication.getName()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<CriancaResponseDto> getCriancaById(@PathVariable Integer id) {
        return ResponseEntity.ok(criancaService.findById(id));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('PARENT')")
    public ResponseEntity<CriancaResponseDto> updateCrianca(
            @PathVariable Integer id,
            @Valid @RequestBody CriancaRequestDto requestDto,
            Authentication authentication) {
        CriancaResponseDto criancaAtualizada = criancaService.update(id, requestDto, authentication.getName());
        return ResponseEntity.ok(criancaAtualizada);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('PARENT')")
    public ResponseEntity<Void> deleteCrianca(@PathVariable Integer id, Authentication authentication) {
        criancaService.delete(id, authentication.getName());
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{criancaId}/vincular-terapeuta")
    @PreAuthorize("hasRole('PARENT')")
    public ResponseEntity<CriancaResponseDto> vincularTerapeuta(
            @PathVariable Integer criancaId,
            @Valid @RequestBody LinkTerapeutaRequestDto requestDto,
            Authentication authentication) {

        CriancaResponseDto criancaAtualizada = criancaService.linkTerapeuta(
                criancaId,
                requestDto.professionalCode(),
                authentication.getName()
        );
        return ResponseEntity.ok(criancaAtualizada);
    }

}
