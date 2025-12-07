package br.edu.ifce.projetoapsback.service;

import br.edu.ifce.projetoapsback.model.Crianca;
import br.edu.ifce.projetoapsback.model.RegistroDeAtividade;
import br.edu.ifce.projetoapsback.model.dto.Message;
import br.edu.ifce.projetoapsback.model.request.OpenAiRequest;
import br.edu.ifce.projetoapsback.model.response.OpenAiResponse;
import br.edu.ifce.projetoapsback.repository.CriancaRepository;
import br.edu.ifce.projetoapsback.repository.RegistroDeAtividadeRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
@RequiredArgsConstructor
public class AiReportService {

    @Value("${openai.api.key}")
    private String apiKey;

    @Value("${openai.model}")
    private String model;

    @Value("${openai.url}")
    private String apiUrl;

    private final CriancaRepository criancaRepository;
    private final RegistroDeAtividadeRepository registroRepository;

    public String gerarRelatorioProgresso(Integer criancaId) {
        // 1. Validar e Buscar a Criança
        Crianca crianca = criancaRepository.findById(criancaId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Criança não encontrada"));

        // 2. Buscar os registros (logs de atividades)
        List<RegistroDeAtividade> registros = registroRepository.findAll().stream()
                .filter(r -> r.getCrianca().getId().equals(crianca.getId()))
                .toList();

        if (registros.isEmpty()) {
            return "Ainda não há registros de atividades suficientes para a Inteligência Artificial gerar uma análise de progresso detalhada.";
        }

        // 3. Montar o Prompt (o comando para a IA)
        String prompt = montarPrompt(crianca, registros);

        // 4. Enviar para a OpenAI e retornar o texto
        return chamarOpenAi(prompt);
    }

    private String montarPrompt(Crianca crianca, List<RegistroDeAtividade> registros) {
        StringBuilder sb = new StringBuilder();

        // Contexto
        sb.append("Você é um terapeuta especialista em análise de desenvolvimento infantil. ");
        sb.append("Gere um relatório de progresso para os pais, com tom profissional, acolhedor e direto.\n\n");

        // Dados Demográficos
        sb.append("--- DADOS DO PACIENTE ---\n");
        sb.append("Nome: ").append(crianca.getNomeCompleto()).append("\n");
        sb.append("Nascimento: ").append(crianca.getDataNascimento()).append("\n");
        if (crianca.getDescricaoDiagnostico() != null) {
            sb.append("Diagnóstico: ").append(crianca.getDescricaoDiagnostico()).append("\n");
        }

        // Dados Comportamentais (Registros)
        sb.append("\n--- HISTÓRICO DE ATIVIDADES REALIZADAS ---\n");
        for (RegistroDeAtividade reg : registros) {
            sb.append("Atividade: ").append(reg.getAtividade().getTitulo()).append("\n");
            sb.append("Status: ").append(reg.getStatus()).append("\n");

            if (reg.getObservacoesDoResponsavel() != null && !reg.getObservacoesDoResponsavel().isBlank()) {
                sb.append("Obs dos Pais: ").append(reg.getObservacoesDoResponsavel()).append("\n");
            }
            if (reg.getFeedbackDoTerapeuta() != null && !reg.getFeedbackDoTerapeuta().isBlank()) {
                sb.append("Feedback Terapêutico: ").append(reg.getFeedbackDoTerapeuta()).append("\n");
            }
            sb.append("Data: ").append(reg.getDataHoraConclusao()).append("\n");
            sb.append("----------------\n");
        }

        // Instruções de Saída
        sb.append("\n--- INSTRUÇÕES DE FORMATAÇÃO ---\n");
        sb.append("Crie o relatório contendo:\n");
        sb.append("1. Resumo do Engajamento (A criança tem feito as atividades?)\n");
        sb.append("2. Análise de Dificuldades (Baseado nos status e obs)\n");
        sb.append("3. Análise de Conquistas\n");
        sb.append("4. Recomendações para a próxima semana\n");
        sb.append("Não use Markdown complexo, use texto corrido e quebras de linha para ficar legível em PDF.");

        return sb.toString();
    }

    private String chamarOpenAi(String prompt) {
        try {
            RestTemplate restTemplate = new RestTemplate();
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.set("Authorization", "Bearer " + apiKey);

            OpenAiRequest requestBody = new OpenAiRequest(
                    model,
                    List.of(new Message("user", prompt))
            );

            HttpEntity<OpenAiRequest> entity = new HttpEntity<>(requestBody, headers);

            ResponseEntity<OpenAiResponse> response = restTemplate.postForEntity(apiUrl, entity, OpenAiResponse.class);

            if (response.getBody() != null && !response.getBody().choices().isEmpty()) {
                return response.getBody().choices().get(0).message().content();
            }

            return "A IA analisou os dados mas não retornou uma resposta válida.";

        } catch (Exception e) {
            return  e.getMessage();
        }
    }
}