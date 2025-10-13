package br.edu.ifce.projetoapsback.resource;

import br.edu.ifce.projetoapsback.model.request.UpdateUserStatusRequestDto;
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

    @GetMapping("/users")
    public ResponseEntity<List<UserAdminResponseDto>> getAllUsers() {
        return ResponseEntity.ok(adminService.getAllUsers());
    }

    @PatchMapping("/users/{userId}/status")
    public ResponseEntity<UserAdminResponseDto> updateUserStatus(
            @PathVariable Integer userId,
            @Valid @RequestBody UpdateUserStatusRequestDto request) {
        return ResponseEntity.ok(adminService.updateUserStatus(userId, request.getActive()));
    }
}