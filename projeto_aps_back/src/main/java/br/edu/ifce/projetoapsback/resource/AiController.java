package br.edu.ifce.projetoapsback.resource;

import br.edu.ifce.projetoapsback.model.AiProgressReport;
import br.edu.ifce.projetoapsback.model.Crianca;
import br.edu.ifce.projetoapsback.model.bridge.ReportAbstraction;
import br.edu.ifce.projetoapsback.model.bridge.ReportFormat;
import br.edu.ifce.projetoapsback.repository.CriancaRepository;
import br.edu.ifce.projetoapsback.service.AiReportService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/ai")
@RequiredArgsConstructor
public class AiController {

    private final AiReportService aiReportService;
    private final CriancaRepository criancaRepository;

    private final Map<String, ReportFormat> formats;

    // Endpoint anterior (JSON/Texto)
    @GetMapping("/relatorio/crianca/{criancaId}")
    @PreAuthorize("hasAuthority('PARENT') or hasAuthority('HEALTH_PROFESSIONAL')")
    public ResponseEntity<Map<String, String>> gerarRelatorioTexto(@PathVariable Integer criancaId) {
        String relatorio = aiReportService.gerarRelatorioProgresso(criancaId);
        return ResponseEntity.ok(Map.of("relatorio", relatorio));
    }

    // ENDPOINT COM BRIDGE
    @GetMapping("/relatorio/crianca/{criancaId}/download")
    @PreAuthorize("hasAuthority('PARENT') or hasAuthority('HEALTH_PROFESSIONAL')")
    public ResponseEntity<byte[]> downloadRelatorio(
            @PathVariable Integer criancaId,
            @RequestParam(defaultValue = "pdf") String format // 'pdf' ou 'xml'
    ) {
        // 1. Gera o texto com a IA
        String conteudoRelatorio = aiReportService.gerarRelatorioProgresso(criancaId);

        // 2. Busca dados auxiliares
        Crianca crianca = criancaRepository.findById(criancaId)
                .orElseThrow(() -> new RuntimeException("Criança não encontrada"));

        // 3. Seleciona a Implementação (Lado direito da ponte)
        // O Map 'formats' do Spring terá chaves como "pdfFormat" e "xmlFormat"
        ReportFormat selectedFormat = formats.get(format.toLowerCase() + "Format");

        if (selectedFormat == null) {
            throw new IllegalArgumentException("Formato não suportado: " + format);
        }

        // 4. Instancia a Abstração (Lado esquerdo da ponte) injetando a implementação
        ReportAbstraction report = new AiProgressReport(selectedFormat, crianca.getNomeCompleto());

        // 5. Executa a ponte
        byte[] fileContent = report.export(conteudoRelatorio);

        // 6. Retorna o arquivo para download
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=relatorio" + report.getExtension())
                .contentType(MediaType.parseMediaType(report.getContentType()))
                .body(fileContent);
    }
}