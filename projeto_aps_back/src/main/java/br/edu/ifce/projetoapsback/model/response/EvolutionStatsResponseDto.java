package br.edu.ifce.projetoapsback.model.response;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

public record EvolutionStatsResponseDto(
        // Para Gráfico de Pizza
        Map<String, Long> statusDistribution,

        // Para Gráfico de Linha
        List<DailyActivityCount> last7DaysHistory
) {
    public record DailyActivityCount(LocalDate date, Long count) {}
}