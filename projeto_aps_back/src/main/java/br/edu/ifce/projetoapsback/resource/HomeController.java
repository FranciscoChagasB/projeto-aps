package br.edu.ifce.projetoapsback.resource;

import br.edu.ifce.projetoapsback.model.response.HomeInfoResponseDto;
import br.edu.ifce.projetoapsback.service.HomeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/home-info")
@RequiredArgsConstructor

public class HomeController {

    private final HomeService homeService;

    @GetMapping
    public ResponseEntity<HomeInfoResponseDto> getHomeInfo(Authentication authentication) {
        return ResponseEntity.ok(homeService.getHomeInfo(authentication.getName()));
    }

}
