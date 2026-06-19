package com.assessment.service;

import com.assessment.dto.BulkCredentialRequest;
import com.assessment.dto.BulkCredentialResponse;
import com.assessment.dto.CredentialDTO;
import com.assessment.exception.CredentialGenerationException;
import com.assessment.model.TestAssignment;
import com.assessment.repository.TestAssignmentRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Orchestration service for bulk credential generation.
 * 
 * Validates: Requirements 6, 14, 15
 * 
 * Responsibilities:
 * - Validate test assignment (exists, is active, has future end date)
 * - Generate unique usernames and secure passwords
 * - Coordinate transaction across auth service and assessment database
 * - Log credential generation audit trail
 * - Return generated credentials with plaintext passwords for display/export
 * 
 * Workflow:
 * 1. Validate test assignment exists and is active
 * 2. Generate unique usernames using UsernameGenerationService
 * 3. Generate secure passwords using PasswordGenerationService
 * 4. Execute atomic credential creation via TransactionCoordinator
 * 5. Log activity via ActivityLogService
 * 6. Return credentials with metadata
 */
@Slf4j
@Service
public class CredentialService {

    @Autowired
    private TestAssignmentRepository testAssignmentRepository;

    @Autowired
    private UsernameGenerationService usernameGenerationService;

    @Autowired
    private PasswordGenerationService passwordGenerationService;

    @Autowired
    private TransactionCoordinator transactionCoordinator;

    @Autowired
    private ActivityLogService activityLogService;

    /**
     * Generate bulk credentials for a test assignment.
     * 
     * Complete workflow:
     * 1. Validate test assignment:
     *    - Must exist
     *    - Must have status "aktif"
     *    - Must have future end date (windowEnd > now)
     * 2. Generate usernames:
     *    - Use pattern: {schoolCode}_{testCode}_{sequence}
     *    - Ensure uniqueness against auth service
     *    - Resolve conflicts with automatic sequence increment
     * 3. Generate passwords:
     *    - 8 characters, mixed case + digits
     *    - No ambiguous characters (0, O, l, 1, I)
     *    - All unique within batch
     * 4. Create credentials atomically:
     *    - Register users in auth service (MongoDB)
     *    - Create assessment user records (PostgreSQL)
     *    - Implement compensating transactions for rollback on failure
     * 5. Log activity:
     *    - Record credential generation event
     *    - Include count and timestamps
     * 6. Return response:
     *    - Include plaintext passwords (only in response, never stored)
     *    - Include school and category metadata
     *    - Include admin username and timestamp
     * 
     * @param request bulk credential request with assignment ID, pattern, and count
     * @param adminUsername username of the admin performing this operation
     * @return bulk credential response with generated credentials and metadata
     * @throws CredentialGenerationException if validation fails or creation fails
     */
    public BulkCredentialResponse generateBulkCredentials(
            BulkCredentialRequest request,
            String adminUsername
    ) throws CredentialGenerationException {
        
        log.info("Starting bulk credential generation: assignmentId={}, count={}, admin={}",
                request.testAssignmentId(), request.count(), adminUsername);
        
        // 1. Validate test assignment
        TestAssignment assignment = validateAssignment(request.testAssignmentId());
        
        log.debug("Test assignment validated: id={}, school={}, category={}",
                assignment.getId(),
                assignment.getSchool().getName(),
                assignment.getCategory().getName());
        
        // 2. Generate unique usernames
        List<String> usernames = usernameGenerationService.generateUniqueUsernames(
                request.schoolCode(),
                request.testCode(),
                request.count()
        );
        
        log.debug("Usernames generated: count={}, first={}, last={}",
                usernames.size(),
                usernames.get(0),
                usernames.get(usernames.size() - 1));
        
        // 3. Generate secure passwords
        List<String> passwords = passwordGenerationService.generateSecurePasswords(request.count());
        
        log.debug("Passwords generated: count={}", passwords.size());
        
        // 4. Create credentials atomically
        List<CredentialDTO> credentials = transactionCoordinator.createCredentialsAtomically(
                usernames,
                passwords,
                assignment.getSchool().getId(),
                assignment.getId()
        );
        
        log.info("Credentials created successfully: count={}", credentials.size());
        
        // 5. Log activity without blocking successful credential generation.
        try {
            activityLogService.logCredentialGeneration(
                    adminUsername,
                    assignment.getSchool().getName(),
                    assignment.getCategory().getName(),
                    request.count()
            );
            log.debug("Activity logged for credential generation");
        } catch (Exception ex) {
            log.warn("Failed to write credential generation audit log: {}", ex.getMessage());
        }
        
        // 6. Return response
        BulkCredentialResponse response = new BulkCredentialResponse(
                credentials,
                assignment.getSchool().getName(),
                assignment.getCategory().getName(),
                request.count(),
                adminUsername,
                LocalDateTime.now()
        );
        
        log.info("Bulk credential generation completed successfully");
        return response;
    }

    /**
     * Validate that a test assignment exists and is eligible for credential generation.
     * 
     * Validation rules:
     * - Assignment must exist (by ID)
     * - Assignment must be active (is_active = true)
     * - Assignment must not have ended (window_end must be null or in the future)
     * - Assignment must have associated school and category
     * 
     * @param assignmentId the ID of the test assignment to validate
     * @return the validated TestAssignment entity
     * @throws CredentialGenerationException if any validation fails
     */
    private TestAssignment validateAssignment(Long assignmentId) throws CredentialGenerationException {
        
        log.debug("Validating test assignment: id={}", assignmentId);
        
        // Check existence
        TestAssignment assignment = testAssignmentRepository.findById(assignmentId)
                .orElseThrow(() -> {
                    String message = "Test assignment not found: id=" + assignmentId;
                    log.error(message);
                    return new CredentialGenerationException(message);
                });
        
        // Check active status
        if (!assignment.isActive()) {
            String message = "Test assignment is not active: id=" + assignmentId;
            log.error(message);
            throw new CredentialGenerationException(message);
        }
        
        // Check end date
        LocalDateTime now = LocalDateTime.now();
        if (assignment.getWindowEnd() != null && assignment.getWindowEnd().isBefore(now)) {
            String message = "Test assignment has ended: id=" + assignmentId + 
                    ", windowEnd=" + assignment.getWindowEnd();
            log.error(message);
            throw new CredentialGenerationException(message);
        }
        
        // Check that school and category are present
        if (assignment.getSchool() == null) {
            String message = "Test assignment has no associated school: id=" + assignmentId;
            log.error(message);
            throw new CredentialGenerationException(message);
        }
        
        if (assignment.getCategory() == null) {
            String message = "Test assignment has no associated category: id=" + assignmentId;
            log.error(message);
            throw new CredentialGenerationException(message);
        }
        
        log.debug("Test assignment validation passed");
        return assignment;
    }
}
