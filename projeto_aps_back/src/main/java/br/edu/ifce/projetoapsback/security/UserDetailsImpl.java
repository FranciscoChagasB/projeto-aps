package br.edu.ifce.projetoapsback.security;

import br.edu.ifce.projetoapsback.model.Address;
import br.edu.ifce.projetoapsback.model.Role;
import br.edu.ifce.projetoapsback.model.User;
import lombok.Getter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.List;
import java.util.stream.Collectors;

@Getter
public class UserDetailsImpl implements UserDetails {

    private final Integer id;
    private final String email;
    private final String password;
    private final String fullName;
    private final String cpf;
    private final String phone;
    private final Address address;
    private final Boolean active;
    private final String professionalCode;
    private final Collection<? extends GrantedAuthority> authorities;

    public UserDetailsImpl(User user) {
        this.id = user.getId();
        this.email = user.getEmail();
        this.password = user.getPassword();
        this.fullName = user.getFullName();
        this.cpf = user.getCpf();
        this.phone = user.getPhone();
        this.address = user.getAddress();
        this.active = user.getActive();
        this.professionalCode = user.getProfessionalCode();
        // Converte as roles do usuário para GrantedAuthority
        this.authorities = mapRolesToAuthorities(user.getRoles());
    }

    private Collection<? extends GrantedAuthority> mapRolesToAuthorities(List<Role> roles) {
        return roles.stream()
                .map(role -> new SimpleGrantedAuthority(role.getName().name()))
                .collect(Collectors.toList());
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    @Override
    public String getPassword() {
        return password;
    }

    @Override
    public String getUsername() {
        return email; // Login será feito pelo e-mail
    }

    @Override
    public boolean isEnabled() {
        // Usar o campo "active" do usuário
        return active != null ? active : true;
    }
}