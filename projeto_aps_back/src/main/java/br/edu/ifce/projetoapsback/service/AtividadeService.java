package br.edu.ifce.projetoapsback.service;

import br.edu.ifce.projetoapsback.model.Atividade;
import br.edu.ifce.projetoapsback.model.request.AtividadeRequestDto;
import br.edu.ifce.projetoapsback.model.response.AtividadeResponseDto;
import br.edu.ifce.projetoapsback.repository.AtividadeRepository;
import br.edu.ifce.projetoapsback.util.mapper.AtividadeMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AtividadeService {

    private final AtividadeRepository atividadeRepository;
    private final AtividadeMapper atividadeMapper;

    public AtividadeResponseDto create(AtividadeRequestDto requestDto) {
        Atividade atividade = atividadeMapper.toEntity(requestDto);
        Atividade atividadeSalva = atividadeRepository.save(atividade);
        return atividadeMapper.toResponseDto(atividadeSalva);
    }

    public List<AtividadeResponseDto> findAll() {
        return atividadeRepository.findAll().stream()
                .map(atividadeMapper::toResponseDto)
                .collect(Collectors.toList());
    }

    public AtividadeResponseDto findById(Integer id) {
        Atividade atividade = atividadeRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Atividade não encontrada com o ID: " + id));
        return atividadeMapper.toResponseDto(atividade);
    }

    public AtividadeResponseDto update(Integer id, AtividadeRequestDto requestDto) {
        Atividade atividadeExistente = atividadeRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Atividade não encontrada com o ID: " + id));

        atividadeMapper.updateEntityFromDto(requestDto, atividadeExistente);
        Atividade atividadeAtualizada = atividadeRepository.save(atividadeExistente);
        return atividadeMapper.toResponseDto(atividadeAtualizada);
    }

    public void delete(Integer id) {
        if (!atividadeRepository.existsById(id)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Atividade não encontrada com o ID: " + id);
        }
        atividadeRepository.deleteById(id);
    }

}
