package br.edu.ifce.projetoapsback.resource;

import br.edu.ifce.projetoapsback.model.request.UserRequestDto;
import br.edu.ifce.projetoapsback.model.request.LoginRequestDto;
import br.edu.ifce.projetoapsback.model.response.RecoveryJwtTokenDto;
import br.edu.ifce.projetoapsback.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/users")
public class UserController {

    @Autowired
    private UserService userService;

    @PostMapping("/login")
    public ResponseEntity<RecoveryJwtTokenDto> authenticateUser(@RequestBody LoginRequestDto loginRequestDto) {
        RecoveryJwtTokenDto token = userService.authenticateUser(loginRequestDto);
        return new ResponseEntity<>(token, HttpStatus.OK);
    }

    @PostMapping
    public ResponseEntity<Void> createUser(@RequestBody UserRequestDto userRequestDto) {
        userService.createUser(userRequestDto);
        return new ResponseEntity<>(HttpStatus.CREATED);
    }

    @GetMapping("/test")
    public ResponseEntity<String> getAuthenticationTest() {
        return new ResponseEntity<>("Autenticado com sucesso", HttpStatus.OK);
    }

    @GetMapping("/test/health")
    public ResponseEntity<String> getCustomerAuthenticationTest() {
        return new ResponseEntity<>("Voluntário autenticado com sucesso", HttpStatus.OK);
    }

    @GetMapping("/test/administrator")
    public ResponseEntity<String> getAdminAuthenticationTest() {
        return new ResponseEntity<>("Administrador autenticado com sucesso", HttpStatus.OK);
    }

}
