package com.assessment.exception;

/**
 * Exception thrown when credential generation fails.
 * 
 * Indicates issues such as:
 * - Invalid or inactive test assignment
 * - Test assignment has ended
 * - Test assignment not found
 * - Failure to generate credentials atomically
 */
public class CredentialGenerationException extends RuntimeException {
    public CredentialGenerationException(String message) {
        super(message);
    }

    public CredentialGenerationException(String message, Throwable cause) {
        super(message, cause);
    }
}
