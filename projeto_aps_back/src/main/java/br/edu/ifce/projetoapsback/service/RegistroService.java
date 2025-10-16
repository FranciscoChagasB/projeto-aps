package br.edu.ifce.projetoapsback.service;

import br.edu.ifce.projetoapsback.model.Atividade;
import br.edu.ifce.projetoapsback.model.Crianca;
import br.edu.ifce.projetoapsback.model.PlanoDeAtividade;
import br.edu.ifce.projetoapsback.model.RegistroDeAtividade;
import br.edu.ifce.projetoapsback.model.request.RegistroRequestDto;
import br.edu.ifce.projetoapsback.model.request.RegistroUpdateRequestDto;
import br.edu.ifce.projetoapsback.model.response.RegistroResponseDto;
import br.edu.ifce.projetoapsback.repository.AtividadeRepository;
import br.edu.ifce.projetoapsback.repository.CriancaRepository;
import br.edu.ifce.projetoapsback.repository.PlanoDeAtividadeRepository;
import br.edu.ifce.projetoapsback.repository.RegistroDeAtividadeRepository;
import br.edu.ifce.projetoapsback.util.mapper.RegistroMapper;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RegistroService {

    private final RegistroDeAtividadeRepository registroRepository;
    private final AtividadeRepository atividadeRepository;
    private final CriancaRepository criancaRepository;
    private final PlanoDeAtividadeRepository planoRepository;
    private final RegistroMapper registroMapper;

    public RegistroResponseDto create(RegistroRequestDto requestDto) {
        Atividade atividade = atividadeRepository.findById(requestDto.atividadeId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Atividade não encontrada"));
        Crianca crianca = criancaRepository.findById(requestDto.criancaId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Criança não encontrada"));
        PlanoDeAtividade plano = planoRepository.findById(requestDto.planoId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Plano não encontrado"));

        RegistroDeAtividade registro = registroMapper.toEntity(requestDto);
        registro.setAtividade(atividade);
        registro.setCrianca(crianca);
        registro.setPlano(plano);

        RegistroDeAtividade registroSalvo = registroRepository.save(registro);
        return registroMapper.toResponseDto(registroSalvo);
    }

    public List<RegistroResponseDto> findByPlanoId(Integer planoId) {
        return registroRepository.findByPlanoId(planoId).stream()
                .map(registroMapper::toResponseDto)
                .collect(Collectors.toList());
    }

    public RegistroResponseDto addFeedback(Integer registroId, String feedback) {
        RegistroDeAtividade registro = registroRepository.findById(registroId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Registro não encontrado"));

        registro.setFeedbackDoTerapeuta(feedback);
        RegistroDeAtividade registroAtualizado = registroRepository.save(registro);
        return registroMapper.toResponseDto(registroAtualizado);
    }

    public RegistroResponseDto updateObservacoes(Integer registroId, String observacoes) {
        RegistroDeAtividade registro = registroRepository.findById(registroId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Registro não encontrado"));


        registro.setObservacoesDoResponsavel(observacoes);
        RegistroDeAtividade registroAtualizado = registroRepository.save(registro);
        return registroMapper.toResponseDto(registroAtualizado);
    }

    public RegistroResponseDto update(Integer registroId, RegistroUpdateRequestDto requestDto) {
        RegistroDeAtividade registro = registroRepository.findById(registroId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Registro não encontrado"));

        registro.setStatus(requestDto.status());
        registro.setObservacoesDoResponsavel(requestDto.observacoesDoResponsavel());
        RegistroDeAtividade registroAtualizado = registroRepository.save(registro);
        return registroMapper.toResponseDto(registroAtualizado);
    }
}
