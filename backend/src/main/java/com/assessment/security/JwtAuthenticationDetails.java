package com.assessment.security;

import lombok.Getter;

@Getter
public class JwtAuthenticationDetails {
    private final String userId;
    private final String username;
    private final String role;

    public JwtAuthenticationDetails(String userId, String username, String role) {
        this.userId = userId;
        this.username = username;
        this.role = role;
    }
}
