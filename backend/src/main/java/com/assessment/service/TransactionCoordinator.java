package com.assessment.service;

import com.assessment.client.AuthServiceClient;
import com.assessment.dto.CredentialDTO;
import com.assessment.exception.CredentialCreationException;
import com.assessment.model.AssessmentUser;
import com.assessment.model.School;
import com.assessment.repository.AssessmentUserRepository;
import com.assessment.repository.SchoolRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Service for coordinating atomic credential creation across two databases.
 * 
 * Validates: Requirements 6.7, 13.4
 * 
 * Implements compensating transaction pattern:
 * 1. Batches credential creation in chunks of 50 for performance
 * 2. For each batch: creates auth user (MongoDB), then assessment user (PostgreSQL)
 * 3. On any failure: rolls back created auth users via compensating deletes
 * 4. Uses Spring @Transactional for PostgreSQL consistency
 * 
 * Batching Strategy:
 * - Process 50 credentials per batch to manage transaction size and memory
 * - Each batch is a separate Spring transaction
 * - On failure in any batch, all previously created auth users are rolled back
 * - PostgreSQL transaction is automatically rolled back by Spring
 */
@Slf4j
@Service
public class TransactionCoordinator {

    @Autowired
    private AuthServiceClient authServiceClient;

    @Autowired
    private AssessmentUserRepository assessmentUserRepository;

    @Autowired
    private SchoolRepository schoolRepository;

    private static final int BATCH_SIZE = 50;

    /**
     * Create credentials atomically across auth service and assessment database.
     * 
     * Process Flow:
     * 1. Batch usernames and passwords into chunks of BATCH_SIZE
     * 2. For each batch, call processBatch which:
     *    a. Registers each user in auth service (MongoDB)
     *    b. Creates corresponding assessment_user record (PostgreSQL, @Transactional)
     *    c. Tracks created authUserIds for potential rollback
     * 3. On any failure, immediately invoke rollback for all created auth users
     * 4. Return list of created credentials on success
     * 
     * @param usernames list of usernames to create
     * @param passwords list of corresponding passwords (same length)
     * @param schoolId the school ID to link created users to
     * @param assignmentId the test assignment ID (for audit/context purposes)
     * @return list of created credentials (username, password, authUserId, createdAt)
     * @throws CredentialCreationException if any error occurs, with rollback already attempted
     */
    public List<CredentialDTO> createCredentialsAtomically(
            List<String> usernames,
            List<String> passwords,
            Long schoolId,
            Long assignmentId
    ) throws CredentialCreationException {

        if (usernames.size() != passwords.size()) {
            throw new CredentialCreationException(
                    "Usernames and passwords lists must have equal length"
            );
        }

        log.info("Starting atomic credential creation: {} credentials for school={}, assignment={}",
                usernames.size(), schoolId, assignmentId);

        List<CredentialDTO> created = new ArrayList<>();
        List<String> createdAuthUserIds = new ArrayList<>();

        try {
            // Process credentials in batches
            for (int i = 0; i < usernames.size(); i += BATCH_SIZE) {
                int end = Math.min(i + BATCH_SIZE, usernames.size());
                List<String> batchUsernames = usernames.subList(i, end);
                List<String> batchPasswords = passwords.subList(i, end);

                log.debug("Processing batch {}/{}: {} credentials (usernames {} to {})",
                        (i / BATCH_SIZE) + 1,
                        (usernames.size() + BATCH_SIZE - 1) / BATCH_SIZE,
                        batchUsernames.size(),
                        i + 1,
                        end);

                List<CredentialDTO> batchResult = processBatch(
                        batchUsernames,
                        batchPasswords,
                        schoolId,
                        assignmentId,
                        createdAuthUserIds
                );

                created.addAll(batchResult);
                log.debug("Batch complete: {} credentials created successfully, total so far: {}",
                        batchResult.size(), created.size());
            }

            log.info("Atomic credential creation completed successfully: {} total credentials created",
                    created.size());
            return created;

        } catch (Exception e) {
            log.error("Error during credential creation after processing {} credentials. " +
                            "Attempting rollback of {} auth users created so far...",
                    created.size(), createdAuthUserIds.size(), e);

            // Attempt rollback of all created auth users
            rollbackAuthUsers(createdAuthUserIds);

            // Throw exception with context
            String message = String.format(
                    "Credential creation failed after processing %d of %d credentials: %s",
                    created.size(),
                    usernames.size(),
                    e.getMessage()
            );
            log.error(message);
            throw new CredentialCreationException(message, e);
        }
    }

    /**
     * Process a single batch of credentials.
     * 
     * This method is wrapped with @Transactional to ensure all assessment_user inserts
     * in this batch are either all committed or all rolled back together.
     * 
     * Per-credential flow:
     * 1. Call authServiceClient.registerUser() to create in auth service (MongoDB)
     * 2. Store the returned authUserId in the createdAuthUserIds list for potential rollback
     * 3. Create corresponding AssessmentUser in PostgreSQL (within this transaction)
     * 4. Add CredentialDTO to batch results
     * 
     * If any credential registration fails:
     * - The exception propagates up
     * - PostgreSQL transaction is automatically rolled back by Spring
     * - Caller catches exception and rollback() is invoked for all authUserIds
     * 
     * @param usernames batch of usernames
     * @param passwords batch of passwords
     * @param schoolId school ID for assessment users
     * @param assignmentId assignment ID (for context/audit)
     * @param createdAuthUserIds accumulating list of all auth user IDs created so far (used for rollback)
     * @return list of created credentials for this batch
     * @throws Exception propagated from auth service or database
     */
    @Transactional
    protected List<CredentialDTO> processBatch(
            List<String> usernames,
            List<String> passwords,
            Long schoolId,
            Long assignmentId,
            List<String> createdAuthUserIds
    ) {
        List<CredentialDTO> batch = new ArrayList<>();

        for (int i = 0; i < usernames.size(); i++) {
            String username = usernames.get(i);
            String password = passwords.get(i);

            log.debug("Creating credential for username: {}", username);

            try {
                // 1. Register user in auth service (MongoDB)
                AuthServiceClient.AuthRegisterResponse authResponse = authServiceClient.registerUser(
                        username,
                        password,
                        "siswa" // role for students
                );

                String authUserId = authResponse.userId();
                createdAuthUserIds.add(authUserId);

                log.debug("User registered in auth service: username={}, authUserId={}", username, authUserId);

                // 2. Create assessment user in PostgreSQL (within this @Transactional context)
                School school = schoolRepository.getById(schoolId);
                
                AssessmentUser assessmentUser = AssessmentUser.builder()
                        .authUserId(authUserId)
                        .username(username)
                        .email(username + "@generated.local") // generated placeholder email
                        .name("Student " + username) // placeholder name
                        .role("siswa")
                        .school(school) // use fetched school reference
                        .afiliatorId(null) // will be assigned by facilitator/counselor
                        .build();

                assessmentUserRepository.save(assessmentUser);

                log.debug("Assessment user created: username={}, authUserId={}, schoolId={}",
                        username, authUserId, schoolId);

                // 3. Create result DTO
                batch.add(new CredentialDTO(
                        username,
                        password, // plaintext - only for immediate display/export, never stored
                        authUserId,
                        LocalDateTime.now()
                ));

            } catch (Exception e) {
                log.error("Failed to create credential for username {}: {}", username, e.getMessage(), e);
                // Exception propagates up to createCredentialsAtomically for rollback handling
                throw e;
            }
        }

        return batch;
    }

    /**
     * Rollback created auth users via compensating transaction.
     * 
     * Called when credential creation fails partway through. This method attempts
     * to delete all auth users that were created before the failure.
     * 
     * Strategy:
     * - Iterate through all authUserIds created before the failure
     * - Call authServiceClient.deleteUser() for each
     * - Log successes and failures independently
     * - Continue rolling back all remaining IDs even if individual deletions fail
     * - Do NOT throw exceptions (all deletions are best-effort)
     * 
     * Why individual deletion failures don't stop rollback:
     * - If one deletion fails, we still want to try deleting the others
     * - Incomplete rollback is better than giving up partway through
     * - Failures are logged for manual intervention if needed
     * 
     * @param authUserIds list of auth user IDs to delete
     */
    private void rollbackAuthUsers(List<String> authUserIds) {
        if (authUserIds.isEmpty()) {
            log.info("No auth users to rollback");
            return;
        }

        log.warn("Starting rollback of {} auth users", authUserIds.size());

        int successCount = 0;
        int failureCount = 0;

        for (String userId : authUserIds) {
            try {
                authServiceClient.deleteUser(userId);
                log.debug("Auth user deleted during rollback: userId={}", userId);
                successCount++;
            } catch (Exception e) {
                log.error("Failed to delete auth user {} during rollback: {}",
                        userId, e.getMessage());
                failureCount++;
                // Continue with remaining deletions despite this failure
            }
        }

        log.warn("Rollback complete: {} deleted successfully, {} failed",
                successCount, failureCount);

        if (failureCount > 0) {
            log.error("Incomplete rollback: {} of {} auth users could not be deleted. " +
                            "Manual cleanup may be required for auth userIds: {}",
                    failureCount, authUserIds.size(), authUserIds);
        }
    }
}
