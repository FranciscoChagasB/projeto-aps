package br.edu.ifce.projetoapsback.service;

import br.edu.ifce.projetoapsback.model.RegistroDeAtividade;
import br.edu.ifce.projetoapsback.model.enumeration.StatusRegistro;
import br.edu.ifce.projetoapsback.model.response.EvolutionStatsResponseDto;
import br.edu.ifce.projetoapsback.repository.RegistroDeAtividadeRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DashboardService {

    private final RegistroDeAtividadeRepository registroRepository;

    public EvolutionStatsResponseDto getEvolutionForChild(Integer criancaId) {
        // 1. Busca DIRETAMENTE do banco apenas os registros daquela criança.
        // Isso resolve o erro de tipagem e é muito mais rápido.
        List<RegistroDeAtividade> registros = registroRepository.findByCriancaId(criancaId);

        // Se quiser garantir que não venha nulo (embora o JPA retorne lista vazia)
        if (registros == null) {
            registros = new ArrayList<>();
        }

        // 2. Calcula Distribuição de Status (Pizza)
        Map<String, Long> statusCount = registros.stream()
                .collect(Collectors.groupingBy(
                        r -> r.getStatus().name(),
                        Collectors.counting()
                ));


        Map<LocalDate, Long> contagemPorDia = registros.stream()
                .filter(r -> r.getDataHoraConclusao() != null) // Proteção contra datas nulas
                .filter(r -> r.getStatus() != StatusRegistro.NAO_CONCLUIDO) // Filtra os concluídos
                .collect(Collectors.groupingBy(
                        r -> r.getDataHoraConclusao().toLocalDate(),
                        Collectors.counting()
                ));

// 2. Agora o loop fica super leve, apenas consultando o mapa
        List<EvolutionStatsResponseDto.DailyActivityCount> history = new ArrayList<>();
        LocalDate today = LocalDate.now();

        for (int i = 6; i >= 0; i--) {
            LocalDate dateToCheck = today.minusDays(i);

            // Pega a contagem do mapa. Se não tiver nada naquele dia, retorna 0.
            Long count = contagemPorDia.getOrDefault(dateToCheck, 0L);

            history.add(new EvolutionStatsResponseDto.DailyActivityCount(dateToCheck, count));
        }

        return new EvolutionStatsResponseDto(statusCount, history);
    }

}
