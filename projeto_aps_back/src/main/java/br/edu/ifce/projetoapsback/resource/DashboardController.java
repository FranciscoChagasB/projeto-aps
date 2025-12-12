package br.edu.ifce.projetoapsback.resource;

import br.edu.ifce.projetoapsback.model.response.EvolutionStatsResponseDto;
import br.edu.ifce.projetoapsback.service.DashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/dashboard")
@RequiredArgsConstructor
public class DashboardController {

    private final DashboardService dashboardService;

    @GetMapping("/evolution/{criancaId}")
    @PreAuthorize("hasAuthority('PARENT') or hasAuthority('HEALTH_PROFESSIONAL')")
    public ResponseEntity<EvolutionStatsResponseDto> getEvolution(@PathVariable Integer criancaId) {
        // TODO: Validar se o usuário logado tem permissão de ver essa criança
        return ResponseEntity.ok(dashboardService.getEvolutionForChild(criancaId));
    }
}