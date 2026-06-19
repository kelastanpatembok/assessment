package com.assessment.controller;

import com.assessment.dto.BulkCredentialRequest;
import com.assessment.dto.BulkCredentialResponse;
import com.assessment.exception.CredentialGenerationException;
import com.assessment.security.CurrentUser;
import com.assessment.service.CredentialService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * REST Controller for credential generation endpoints.
 * 
 * Validates: Requirements 1, 6, 12
 * 
 * Responsibilities:
 * - Expose POST /api/credentials/bulk-generate endpoint
 * - Enforce SUPERADMIN role requirement
 * - Extract admin username from JWT authentication
 * - Validate request using @Valid annotations
 * - Return 201 Created on success
 * - Delegate to CredentialService for business logic
 * - Automatic exception mapping via GlobalExceptionHandler
 * 
 * Security:
 * - All endpoints require SUPERADMIN role
 * - Admin username extracted from JWT claims via CurrentUser utility
 * - Request validation enforced at controller level
 */
@Slf4j
@RestController
@RequestMapping("/api/credentials")
@PreAuthorize("hasRole('SUPERADMIN')")
@RequiredArgsConstructor
public class CredentialController {

    private final CredentialService credentialService;

    /**
     * Generate bulk credentials for a test assignment.
     * 
     * Endpoint: POST /api/credentials/bulk-generate
     * 
     * Request body must include:
     * - testAssignmentId: ID of the test assignment (required)
     * - schoolCode: School identifier (max 10 chars, alphanumeric + underscore, required)
     * - testCode: Test type identifier (max 10 chars, alphanumeric + underscore, required)
     * - count: Number of credentials to generate (1-500, required)
     * 
     * Success response (201 Created):
     * {
     *   "credentials": [
     *     {
     *       "username": "ABC_TST_001",
     *       "password": "XyZ9AbC2",
     *       "authUserId": "mongodb-object-id",
     *       "createdAt": "2024-01-15T10:30:00"
     *     },
     *     ...
     *   ],
     *   "schoolName": "SMA Negeri 1",
     *   "testCategory": "IQ Test",
     *   "count": 10,
     *   "createdBy": "admin-username",
     *   "createdAt": "2024-01-15T10:30:00"
     * }
     * 
     * Error responses are mapped by GlobalExceptionHandler:
     * - 400 Bad Request: Invalid request parameters or validation failure
     * - 403 Forbidden: User does not have SUPERADMIN role
     * - 404 Not Found: Test assignment not found
     * - 422 Unprocessable Entity: Test assignment not active or has ended
     * - 500 Internal Server Error: Service failure (auth service unavailable, database error, rollback occurred)
     * 
     * @param request the bulk credential generation request with validation constraints
     * @return ResponseEntity with HTTP 201 Created and BulkCredentialResponse body
     * @throws CredentialGenerationException if generation fails (validation, service, or rollback)
     */
    @PostMapping("/bulk-generate")
    public ResponseEntity<BulkCredentialResponse> generateBulkCredentials(
            @Valid @RequestBody BulkCredentialRequest request
    ) throws CredentialGenerationException {
        
        String adminUsername = CurrentUser.username();
        
        log.info("Credential generation request received: admin={}, assignmentId={}, count={}",
                adminUsername, request.testAssignmentId(), request.count());
        
        BulkCredentialResponse response = credentialService.generateBulkCredentials(request, adminUsername);
        
        log.info("Credential generation completed successfully: admin={}, count={}",
                adminUsername, response.count());
        
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }
}
