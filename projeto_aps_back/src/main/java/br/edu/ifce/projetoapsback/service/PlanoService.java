package br.edu.ifce.projetoapsback.service;

import br.edu.ifce.projetoapsback.model.Atividade;
import br.edu.ifce.projetoapsback.model.Crianca;
import br.edu.ifce.projetoapsback.model.PlanoDeAtividade;
import br.edu.ifce.projetoapsback.model.User;
import br.edu.ifce.projetoapsback.model.request.PlanoRequestDto;
import br.edu.ifce.projetoapsback.model.request.PlanoUpdateRequestDto;
import br.edu.ifce.projetoapsback.model.response.PlanoResponseDto;
import br.edu.ifce.projetoapsback.repository.AtividadeRepository;
import br.edu.ifce.projetoapsback.repository.CriancaRepository;
import br.edu.ifce.projetoapsback.repository.PlanoDeAtividadeRepository;
import br.edu.ifce.projetoapsback.repository.UserRepository;
import br.edu.ifce.projetoapsback.util.mapper.PlanoMapper;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PlanoService {

    private final PlanoDeAtividadeRepository planoRepository;
    private final UserRepository userRepository;
    private final CriancaRepository criancaRepository;
    private final AtividadeRepository atividadeRepository;
    private final PlanoMapper planoMapper;

    public PlanoResponseDto create(PlanoRequestDto requestDto, String terapeutaEmail) {
        User terapeuta = userRepository.findByEmail(terapeutaEmail)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Terapeuta não encontrado"));

        Crianca crianca = criancaRepository.findById(requestDto.criancaId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Criança não encontrada"));

        List<Atividade> atividades = atividadeRepository.findAllById(requestDto.atividadeIds());
        if (atividades.size() != requestDto.atividadeIds().size()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Uma ou mais atividades não foram encontradas.");
        }

        PlanoDeAtividade plano = planoMapper.toEntity(requestDto);
        plano.setTerapeuta(terapeuta);
        plano.setCrianca(crianca);
        plano.setAtividades(atividades);

        PlanoDeAtividade planoSalvo = planoRepository.save(plano);
        return planoMapper.toResponseDto(planoSalvo);
    }

    public List<PlanoResponseDto> findByCriancaId(Integer criancaId) {
        // Adicionar verificação de permissão aqui também
        return planoRepository.findByCriancaId(criancaId).stream()
                .map(planoMapper::toResponseDto)
                .collect(Collectors.toList());
    }

    public PlanoResponseDto findById(Integer id) {
        PlanoDeAtividade plano = planoRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Plano não encontrado"));
        return planoMapper.toResponseDto(plano);
    }

    @Transactional
    public PlanoResponseDto addAtividades(Integer planoId, List<Integer> atividadeIds) {
        PlanoDeAtividade plano = planoRepository.findById(planoId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Plano não encontrado"));

        // Lógica de permissão (verificar se o terapeuta logado é o dono do plano) aqui

        List<Atividade> novasAtividades = atividadeRepository.findAllById(atividadeIds);
        plano.getAtividades().addAll(novasAtividades); // Adiciona as novas atividades à lista existente

        planoRepository.save(plano);
        return planoMapper.toResponseDto(plano);
    }

    @Transactional
    public PlanoResponseDto removeAtividades(Integer planoId, List<Long> atividadeIds) {
        PlanoDeAtividade plano = planoRepository.findById(planoId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Plano não encontrado"));

        // Remove da lista de atividades do plano aquelas cujos IDs foram passados
        plano.getAtividades().removeIf(atividade -> atividadeIds.contains(atividade.getId()));

        planoRepository.save(plano);
        return planoMapper.toResponseDto(plano);
    }

    public void delete(Integer id, String terapeutaEmail) {
        User terapeuta = findUserByEmail(terapeutaEmail);
        PlanoDeAtividade plano = findPlanoById(id);
        checkTerapeutaPermission(plano, terapeuta);
        planoRepository.deleteById(id);
    }

    // Métodos utilitários
    private User findUserByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuário não encontrado"));
    }

    private Crianca findCriancaById(Integer id) {
        return criancaRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Criança não encontrada"));
    }

    private PlanoDeAtividade findPlanoById(Integer id) {
        return planoRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Plano não encontrado"));
    }

    private void checkTerapeutaPermission(PlanoDeAtividade plano, User terapeuta) {
        if (!plano.getTerapeuta().getId().equals(terapeuta.getId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Você não tem permissão para modificar este plano.");
        }
    }

    public PlanoResponseDto update(Integer id, PlanoUpdateRequestDto requestDto, String terapeutaEmail) {
        User terapeuta = findUserByEmail(terapeutaEmail);
        PlanoDeAtividade plano = findPlanoById(id);
        checkTerapeutaPermission(plano, terapeuta);

        plano.setNome(requestDto.nome());
        plano.setObjetivo(requestDto.objetivo());

        PlanoDeAtividade planoAtualizado = planoRepository.save(plano);
        return planoMapper.toResponseDto(planoAtualizado);
    }
}
