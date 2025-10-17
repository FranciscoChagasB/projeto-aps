package br.edu.ifce.projetoapsback.resource;

import br.edu.ifce.projetoapsback.model.User;
import br.edu.ifce.projetoapsback.model.request.UpdateUserStatusRequestDto;
import br.edu.ifce.projetoapsback.model.request.UserRequestDto;
import br.edu.ifce.projetoapsback.model.response.UserAdminResponseDto;
import br.edu.ifce.projetoapsback.service.AdminService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/admin")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMINISTRATOR')") // Garante que só admins acessem
public class AdminController {

    private final AdminService adminService;

    @PostMapping
    public ResponseEntity<User> create(@RequestBody UserRequestDto user) {
        return ResponseEntity.ok(adminService.createUser(user));
    }

    @GetMapping
    public ResponseEntity<List<User>> getAll(
            @RequestParam(required = false) String email,
            @RequestParam(required = false) String cpf,
            @RequestParam(required = false) String fullName,
            @RequestParam(required = false) Boolean active,
            @RequestParam(required = false) String professionalCode
    ) {
        return ResponseEntity.ok(adminService.getAll(email, cpf, fullName, active, professionalCode));
    }

    @GetMapping("/{id}")
    public ResponseEntity<User> getById(@PathVariable Integer id) {
        return ResponseEntity.ok(adminService.getById(id));
    }

    @PutMapping("/{id}")
    public ResponseEntity<User> update(@PathVariable Integer id, @RequestBody UserRequestDto user) {
        return ResponseEntity.ok(adminService.update(id, user));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Integer id) {
        adminService.delete(id);
        return ResponseEntity.noContent().build();
    }
}