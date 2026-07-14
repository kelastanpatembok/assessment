package com.assessment.controller;

import com.assessment.dto.BulkCredentialRequest;
import com.assessment.dto.BulkCredentialResponse;
import com.assessment.exception.CredentialGenerationException;
import com.assessment.exception.ResourceNotFoundException;
import com.assessment.model.CredentialBatch;
import com.assessment.repository.CredentialBatchRepository;
import com.assessment.security.CurrentUser;
import com.assessment.service.CredentialService;
import com.assessment.service.CredentialStorageService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.nio.charset.StandardCharsets;
import java.util.List;

/**
 * REST Controller for credential generation endpoints.
 * 
 * Validates: Requirements 1, 6, 12
 * 
 * Responsibilities:
 * - Expose POST /credentials/bulk-generate endpoint under the global /api context path
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
@RequestMapping("/credentials")
@PreAuthorize("hasRole('SUPERADMIN')")
@RequiredArgsConstructor
public class CredentialController {

    private final CredentialService credentialService;
    private final CredentialBatchRepository credentialBatchRepository;
    private final CredentialStorageService credentialStorageService;

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

    /**
     * List previously generated credential PDF batches, optionally filtered by assignment.
     *
     * Endpoint: GET /api/credentials/batches?testAssignmentId={id}
     * Never includes the plaintext credentials themselves — only batch metadata
     * (school, category, count, who generated it, when). The PDF is fetched separately
     * via /credentials/batches/{id}/download.
     */
    @GetMapping("/batches")
    public ResponseEntity<List<CredentialBatch>> listBatches(
            @RequestParam(required = false) Long testAssignmentId
    ) {
        List<CredentialBatch> batches = testAssignmentId != null
                ? credentialBatchRepository.findByTestAssignmentIdOrderByCreatedAtDesc(testAssignmentId)
                : credentialBatchRepository.findAllByOrderByCreatedAtDesc();
        return ResponseEntity.ok(batches);
    }

    /**
     * Download a previously generated credential PDF (contains plaintext passwords).
     *
     * Endpoint: GET /api/credentials/batches/{id}/download
     * Gated by the class-level SUPERADMIN requirement — never exposed as a public/static file.
     */
    @GetMapping("/batches/{id}/download")
    public ResponseEntity<byte[]> downloadBatch(@PathVariable Long id) {
        CredentialBatch batch = credentialBatchRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Credential batch not found: " + id));

        byte[] pdfBytes = credentialStorageService.read(id);

        String encodedFilename = java.net.URLEncoder.encode(batch.getPdfFilename(), StandardCharsets.UTF_8);

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_PDF)
                .header(HttpHeaders.CONTENT_DISPOSITION,
                        "attachment; filename*=UTF-8''" + encodedFilename)
                .body(pdfBytes);
    }

    /**
     * Deletes a stored credential batch (metadata + PDF file). Does not affect the
     * student accounts themselves — only the retained printable record of their credentials.
     */
    @DeleteMapping("/batches/{id}")
    public ResponseEntity<Void> deleteBatch(@PathVariable Long id) {
        CredentialBatch batch = credentialBatchRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Credential batch not found: " + id));

        credentialStorageService.delete(id);
        credentialBatchRepository.delete(batch);

        return ResponseEntity.noContent().build();
    }
}
