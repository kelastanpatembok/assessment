package com.assessment.service;

import com.assessment.client.AuthServiceClient;
import com.assessment.exception.UsernameGenerationException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.regex.Pattern;

/**
 * Service for generating unique sequential usernames for bulk credential generation.
 * 
 * Validates: Requirements 3, 10
 * 
 * Handles:
 * - Sequential username generation with pattern template: {schoolCode}_{testCode}_{sequence}
 * - Uniqueness validation against existing usernames in auth service
 * - Conflict resolution with automatic sequence increment (up to 1000 attempts per username)
 * - Validation of pattern components (alphanumeric + underscore, max 10 chars)
 */
@Slf4j
@Service
public class UsernameGenerationService {

    private final AuthServiceClient authServiceClient;

    public UsernameGenerationService(AuthServiceClient authServiceClient) {
        this.authServiceClient = authServiceClient;
    }

    private static final int MAX_SEQUENCE_ATTEMPTS = 1000;
    private static final int MAX_CODE_LENGTH = 10;
    private static final Pattern VALID_PATTERN = Pattern.compile("^[A-Za-z0-9_]+$");

    /**
     * Generate a list of unique sequential usernames.
     * 
     * Algorithm:
     * 1. Validate pattern components (schoolCode and testCode)
     * 2. Generate initial candidate list: {schoolCode}_{testCode}_001, _002, ..., _{count}
     * 3. Check existing usernames in auth service (batch call)
     * 4. For conflicts, find next available sequence number (max 1000 attempts each)
     * 5. Return list of unique usernames
     * 
     * @param schoolCode the school identifier (max 10 chars, alphanumeric + underscore)
     * @param testCode the test identifier (max 10 chars, alphanumeric + underscore)
     * @param count the number of unique usernames to generate (1-500)
     * @return list of unique usernames
     * @throws UsernameGenerationException if pattern validation fails or unique usernames cannot be generated
     */
    public List<String> generateUniqueUsernames(
            String schoolCode,
            String testCode,
            int count
    ) throws UsernameGenerationException {
        
        // Validate pattern components
        validatePatternComponent(schoolCode, "schoolCode");
        validatePatternComponent(testCode, "testCode");
        
        log.info("Generating {} unique usernames with pattern: {}_{}_{{sequence}}", count, schoolCode, testCode);
        
        String prefix = String.format("%s_%s_", schoolCode, testCode);
        List<String> candidates = new ArrayList<>();
        
        // Generate initial candidate list with zero-padded sequence numbers
        for (int i = 1; i <= count; i++) {
            candidates.add(String.format("%s%03d", prefix, i));
        }
        
        log.debug("Generated {} candidate usernames", candidates.size());
        
        // Check for existing usernames in auth service
        Set<String> existing = authServiceClient.checkUsernamesExist(candidates);
        log.debug("Found {} existing usernames in auth service", existing.size());
        
        // Resolve conflicts and build final unique username list
        List<String> unique = new ArrayList<>();
        int sequenceOffset = count + 1;
        
        for (String candidate : candidates) {
            if (!existing.contains(candidate)) {
                unique.add(candidate);
            } else {
                log.debug("Username conflict detected: {}", candidate);
                
                // Find next available sequence number
                String resolved = resolveConflict(prefix, sequenceOffset, existing);
                if (resolved == null) {
                    String error = String.format(
                        "Could not generate unique username after %d attempts. Pattern: %s, offset: %d",
                        MAX_SEQUENCE_ATTEMPTS,
                        prefix,
                        sequenceOffset
                    );
                    log.error(error);
                    throw new UsernameGenerationException(error);
                }
                
                log.debug("Resolved username conflict: {} -> {}", candidate, resolved);
                unique.add(resolved);
                existing.add(resolved); // prevent duplicate resolution
                sequenceOffset++;
            }
        }
        
        log.info("Successfully generated {} unique usernames", unique.size());
        return unique;
    }

    /**
     * Resolve a username conflict by finding the next available sequence number.
     * 
     * Attempts up to MAX_SEQUENCE_ATTEMPTS to find an unused username by incrementing
     * the sequence number.
     * 
     * @param prefix the username prefix (e.g., "SCHOOL_TEST_")
     * @param startSeq the starting sequence number
     * @param existing set of already-existing usernames
     * @return a unique username, or null if no available username found within MAX_SEQUENCE_ATTEMPTS
     */
    private String resolveConflict(String prefix, int startSeq, Set<String> existing) {
        for (int i = 0; i < MAX_SEQUENCE_ATTEMPTS; i++) {
            String candidate = String.format("%s%03d", prefix, startSeq + i);
            if (!existing.contains(candidate)) {
                log.trace("Conflict resolved at sequence offset {}", i);
                return candidate;
            }
        }
        return null;
    }

    /**
     * Validate a pattern component (schoolCode or testCode).
     * 
     * Rules:
     * - Must not be null or empty
     * - Must be at most 10 characters long
     * - Must contain only alphanumeric characters and underscores
     * 
     * @param component the pattern component to validate
     * @param componentName the name of the component (for error messages)
     * @throws UsernameGenerationException if validation fails
     */
    private void validatePatternComponent(String component, String componentName) 
            throws UsernameGenerationException {
        
        if (component == null || component.isEmpty()) {
            String error = String.format("%s cannot be null or empty", componentName);
            log.error(error);
            throw new UsernameGenerationException(error);
        }
        
        if (component.length() > MAX_CODE_LENGTH) {
            String error = String.format(
                "%s exceeds maximum length of %d characters (length: %d)",
                componentName,
                MAX_CODE_LENGTH,
                component.length()
            );
            log.error(error);
            throw new UsernameGenerationException(error);
        }
        
        if (!VALID_PATTERN.matcher(component).matches()) {
            String error = String.format(
                "%s contains invalid characters. Only alphanumeric characters and underscores are allowed (value: %s)",
                componentName,
                component
            );
            log.error(error);
            throw new UsernameGenerationException(error);
        }
        
        log.trace("Pattern component validated: {}={}", componentName, component);
    }
}
