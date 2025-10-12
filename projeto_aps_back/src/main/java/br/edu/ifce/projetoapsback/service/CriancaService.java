package br.edu.ifce.projetoapsback.service;

import br.edu.ifce.projetoapsback.model.Crianca;
import br.edu.ifce.projetoapsback.model.User;
import br.edu.ifce.projetoapsback.model.request.CriancaRequestDto;
import br.edu.ifce.projetoapsback.model.response.CriancaResponseDto;
import br.edu.ifce.projetoapsback.repository.CriancaRepository;
import br.edu.ifce.projetoapsback.repository.UserRepository;
import br.edu.ifce.projetoapsback.util.mapper.CriancaMapper;
import jakarta.validation.constraints.NotBlank;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CriancaService {

    private final CriancaRepository criancaRepository;
    private final UserRepository userRepository;
    private final CriancaMapper criancaMapper;

    public CriancaResponseDto create(CriancaRequestDto requestDto, String responsavelEmail) {
        User responsavel = userRepository.findByEmail(responsavelEmail)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuário responsável não encontrado"));

        Crianca crianca = criancaMapper.toEntity(requestDto);
        crianca.setResponsavel(responsavel); // Associa o pai/responsável logado

        // Lógica para associar terapeutas, se houver Ids na requisição
        if (requestDto.terapeutaIds() != null && !requestDto.terapeutaIds().isEmpty()) {
            List<User> terapeutas = userRepository.findAllById(requestDto.terapeutaIds());
            crianca.setTerapeutas(terapeutas);
        }

        Crianca criancaSalva = criancaRepository.save(crianca);
        return criancaMapper.toResponseDto(criancaSalva);
    }

    public List<CriancaResponseDto> findByResponsavel(String responsavelEmail) {
        User responsavel = userRepository.findByEmail(responsavelEmail)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuário responsável não encontrado"));

        return criancaRepository.findByResponsavelId(responsavel.getId()).stream()
                .map(criancaMapper::toResponseDto)
                .collect(Collectors.toList());
    }

    public List<CriancaResponseDto> findByTerapeuta(String terapeutaEmail) {
        User terapeuta = userRepository.findByEmail(terapeutaEmail)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Terapeuta não encontrado"));

        return criancaRepository.findByTerapeutasId(terapeuta.getId()).stream()
                .map(criancaMapper::toResponseDto)
                .collect(Collectors.toList());
    }

    public CriancaResponseDto findById(Integer id) {
        // AQUI DEVE-SE ADICIONAR UMA LÓGICA DE PERMISSÃO
        // Ex: verificar se o usuário logado é o responsável ou um dos terapeutas da criança
        Crianca crianca = criancaRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Criança não encontrada"));
        return criancaMapper.toResponseDto(crianca);
    }

    public CriancaResponseDto update(Integer id, CriancaRequestDto requestDto, String responsavelEmail) {
        User responsavel = userRepository.findByEmail(responsavelEmail)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuário responsável não encontrado"));

        Crianca crianca = criancaRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Criança não encontrada"));

        // Validação de Permissão: Garante que apenas o responsável pela criança pode editá-la
        if (!crianca.getResponsavel().getId().equals(responsavel.getId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Você não tem permissão para editar esta criança.");
        }

        // Mapeia os novos dados do DTO para a entidade existente
        criancaMapper.updateEntityFromDto(requestDto, crianca);

        // Lógica para atualizar a lista de terapeutas
        if (requestDto.terapeutaIds() != null) {
            List<User> terapeutas = userRepository.findAllById(requestDto.terapeutaIds());
            crianca.setTerapeutas(terapeutas);
        }

        Crianca criancaSalva = criancaRepository.save(crianca);
        return criancaMapper.toResponseDto(criancaSalva);
    }

    public void delete(Integer id, String responsavelEmail) {
        User responsavel = findUserByEmail(responsavelEmail);
        Crianca crianca = findCriancaById(id);

        if (!crianca.getResponsavel().getId().equals(responsavel.getId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Você não tem permissão para deletar esta criança.");
        }
        criancaRepository.deleteById(id);
    }

    private User findUserByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuário não encontrado com o email: " + email));
    }

    private Crianca findCriancaById(Integer id) {
        return criancaRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Criança não encontrada com o ID: " + id));
    }

    @Transactional // Garante que a operação seja atômica
    public CriancaResponseDto linkTerapeuta(Integer criancaId, String professionalCode, String responsavelEmail) {
        // 1. Valida se o usuário logado é o responsável pela criança
        User responsavel = findUserByEmail(responsavelEmail);
        Crianca crianca = findCriancaById(criancaId);

        if (!crianca.getResponsavel().getId().equals(responsavel.getId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Você não tem permissão para gerenciar esta criança.");
        }

        // 2. Encontra o terapeuta pelo código fornecido
        User terapeuta = userRepository.findByProfessionalCode(professionalCode)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Nenhum profissional encontrado com este código."));

        // 3. Verifica se o vínculo já não existe
        if (crianca.getTerapeutas().stream().anyMatch(t -> t.getId().equals(terapeuta.getId()))) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Este profissional já acompanha esta criança.");
        }

        // 4. Adiciona o terapeuta à lista da criança e salva
        crianca.getTerapeutas().add(terapeuta);
        Crianca criancaSalva = criancaRepository.save(crianca);

        return criancaMapper.toResponseDto(criancaSalva);
    }
}
