package com.assessment.client;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.HttpServerErrorException;
import org.springframework.web.client.ResourceAccessException;
import org.springframework.web.client.RestClient;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * HTTP client for auth service REST API communication.
 * Handles credential-related operations: user registration, username existence checks, and user deletion.
 * 
 * Communicates with the Auth Service (MongoDB) running on port 2000.
 * 
 * Validates: Requirements 6.1, 13.1
 */
@Slf4j
@Component
public class AuthServiceClient {

    private final RestClient restClient;
    private final String authBaseUrl;

    public AuthServiceClient(@Value("${app.auth-base-url}") String authBaseUrl) {
        this.authBaseUrl = authBaseUrl;
        this.restClient = RestClient.builder()
                .baseUrl(authBaseUrl)
                .build();
    }

    /**
     * Register a new user in the auth service with the given credentials.
     * 
     * @param username the username for the new user
     * @param password the password for the new user
     * @param role the role to assign (typically "siswa" for students)
 * @return AuthRegisterResponse containing token and nested user payload
     * @throws RuntimeException if auth service is unavailable or registration fails
     */
    public AuthRegisterResponse registerUser(String username, String password, String role) {
        try {
            log.debug("Registering user in auth service: username={}", username);
            
            String uri = UriComponentsBuilder.fromPath("/auth/register")
                    .queryParam("username", username)
                    .queryParam("email", username + "@generated.local")
                    .queryParam("password", password)
                    .queryParam("name", "Student " + username)
                    .queryParam("platformId", "assessment")
                    .queryParam("role", role)
                    .toUriString();

            AuthRegisterResponse response = restClient.post()
                    .uri(uri)
                    .retrieve()
                    .body(AuthRegisterResponse.class);
            
            log.debug("User registered successfully: username={}, userId={}", username, response.userId());
            return response;
            
        } catch (ResourceAccessException ex) {
            log.error("Auth service unavailable while registering user {}: {}", username, ex.getMessage());
            throw new RuntimeException("Auth service is unavailable: " + ex.getMessage(), ex);
        } catch (HttpServerErrorException ex) {
            log.error("Auth service error while registering user {}: {} {}", username, ex.getStatusCode(), ex.getMessage());
            throw new RuntimeException("Auth service error: " + ex.getMessage(), ex);
        } catch (HttpClientErrorException ex) {
            log.error("Bad request to auth service while registering user {}: {} {}", username, ex.getStatusCode(), ex.getMessage());
            throw new RuntimeException("Invalid request to auth service: " + ex.getMessage(), ex);
        } catch (Exception ex) {
            log.error("Unexpected error while registering user {} in auth service: {}", username, ex.getMessage());
            throw new RuntimeException("Failed to register user in auth service: " + ex.getMessage(), ex);
        }
    }

    /**
     * Check which usernames already exist in the auth service.
     * 
     * Uses batch endpoint for efficiency. Falls back to graceful degradation if endpoint
     * is not available in older auth service versions.
     * 
     * @param usernames list of usernames to check
     * @return set of existing usernames
     * @throws RuntimeException if auth service is unavailable
     */
    public Set<String> checkUsernamesExist(List<String> usernames) {
        if (usernames == null || usernames.isEmpty()) {
            return new HashSet<>();
        }
        
        try {
            log.debug("Checking username existence for {} usernames", usernames.size());
            
            CheckUsernameResponse response = restClient.post()
                    .uri("/auth/users/check-existence")
                    .body(new CheckUsernameRequest(usernames))
                    .retrieve()
                    .body(CheckUsernameResponse.class);
            
            Set<String> existing = response != null && response.existing() != null 
                    ? new HashSet<>(response.existing()) 
                    : new HashSet<>();
            
            log.debug("Username check complete: {} existing usernames found", existing.size());
            return existing;
            
        } catch (ResourceAccessException ex) {
            log.error("Auth service unavailable while checking usernames: {}", ex.getMessage());
            throw new RuntimeException("Auth service is unavailable: " + ex.getMessage(), ex);
        } catch (HttpServerErrorException ex) {
            log.error("Auth service error while checking usernames: {} {}", ex.getStatusCode(), ex.getMessage());
            throw new RuntimeException("Auth service error: " + ex.getMessage(), ex);
        } catch (HttpClientErrorException.NotFound ex) {
            // Endpoint may not exist in older auth service versions - treat as no existing usernames
            log.warn("Username check endpoint not found in auth service (endpoint may not exist yet). Assuming no conflicts.");
            return new HashSet<>();
        } catch (Exception ex) {
            log.error("Unexpected error while checking usernames in auth service: {}", ex.getMessage());
            throw new RuntimeException("Failed to check usernames in auth service: " + ex.getMessage(), ex);
        }
    }

    /**
     * Delete a user from the auth service by ID.
     * 
     * Used for rollback operations when credential creation fails partially.
     * 
     * @param userId the ID of the user to delete
     * @throws RuntimeException if auth service is unavailable or deletion fails
     */
    public void deleteUser(String userId) {
        try {
            log.debug("Deleting user from auth service: userId={}", userId);
            
            restClient.delete()
                    .uri("/users/{userId}", userId)
                    .retrieve()
                    .toBodilessEntity();
            
            log.debug("User deleted successfully: userId={}", userId);
            
        } catch (ResourceAccessException ex) {
            log.error("Auth service unavailable while deleting user {}: {}", userId, ex.getMessage());
            throw new RuntimeException("Auth service is unavailable: " + ex.getMessage(), ex);
        } catch (HttpServerErrorException ex) {
            log.error("Auth service error while deleting user {}: {} {}", userId, ex.getStatusCode(), ex.getMessage());
            throw new RuntimeException("Auth service error: " + ex.getMessage(), ex);
        } catch (HttpClientErrorException ex) {
            log.error("Error deleting user {} from auth service: {} {}", userId, ex.getStatusCode(), ex.getMessage());
            throw new RuntimeException("Failed to delete user from auth service: " + ex.getMessage(), ex);
        } catch (Exception ex) {
            log.error("Unexpected error while deleting user {} from auth service: {}", userId, ex.getMessage());
            throw new RuntimeException("Failed to delete user in auth service: " + ex.getMessage(), ex);
        }
    }

    /**
     * Response from auth service user registration endpoint.
     */
    public record AuthRegisterResponse(
            String token,
            UserInfo user,
            long expiresIn
    ) {
        public String userId() {
            return user != null ? user.id() : null;
        }
    }

    public record UserInfo(
            String id,
            String username,
            String email,
            String name,
            String role,
            String platformId
    ) {}

    /**
     * Request payload for batch username existence check.
     */
    record CheckUsernameRequest(List<String> usernames) {}

    /**
     * Response payload from batch username existence check.
     */
    record CheckUsernameResponse(List<String> existing) {}
}
