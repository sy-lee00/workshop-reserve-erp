package com.project.dia.config.security;

import com.project.dia.model.vo.User;
import lombok.Data;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.io.Serializable;
import java.util.Collection;

@Data
public class PrincipalDetails implements UserDetails, Serializable {

    private static final long serialVersionUID = 1L;
    private User user; // 콤포지션
    private Collection<? extends GrantedAuthority> authorities;

    public PrincipalDetails(User user, Collection<? extends GrantedAuthority> authorities) {
        this.user = user;
        this.authorities = authorities;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    @Override
    public String getPassword() {
        return user.getPassword();
    }

    @Override
    public String getUsername() {
        return user.getEmail();
    }

    // 계정 만료/잠금 여부 등 (DB에 active 컬럼이 있으므로 활용)
    @Override
    public boolean isAccountNonExpired() { return true; }
    @Override
    public boolean isAccountNonLocked() { return true; }
    @Override
    public boolean isCredentialsNonExpired() { return true; }

    @Override
    public boolean isEnabled() {
        // DB의 active 컬럼 (true면 활성, false면 비활성)
        return user.isActive();
    }
}