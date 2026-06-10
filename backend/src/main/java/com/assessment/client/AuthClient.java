package com.assessment.client;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.Map;

/**
 * Thin wrapper around the auth service REST API.
 * Used to register new users (students, counselors, affiliators) from within
 * the assessment backend without the user going through the frontend login flow.
 */
@Slf4j
@Component
public class AuthClient {

    private final RestClient restClient;

    public AuthClient(@Value("${auth.base-url}") String authBaseUrl) {
        this.restClient = RestClient.builder()
                .baseUrl(authBaseUrl)
                .build();
    }

    /**
     * Register a new user in the auth server with the given role.
     * Returns the token from the auth response, or null on failure.
     */
    public AuthRegisterResponse register(String username, String email, String password,
                                         String name, String role) {
        try {
            String uri = UriComponentsBuilder.fromPath("/auth/register")
                    .queryParam("username", username)
                    .queryParam("email", email)
                    .queryParam("password", password)
                    .queryParam("name", name)
                    .queryParam("platformId", "assessment")
                    .queryParam("role", role)
                    .toUriString();

            return restClient.post()
                    .uri(uri)
                    .retrieve()
                    .body(AuthRegisterResponse.class);
        } catch (Exception ex) {
            log.error("Auth register failed for username={}: {}", username, ex.getMessage());
            throw new RuntimeException("Failed to register user in auth service: " + ex.getMessage(), ex);
        }
    }

    public record AuthRegisterResponse(String token, UserInfo user, long expiresIn) {}
    public record UserInfo(String id, String username, String email, String name, String role, String platformId) {}
}
