package com.assessment.exception;

/**
 * Exception thrown when username generation fails.
 * 
 * Indicates issues such as:
 * - Invalid pattern components (schoolCode or testCode)
 * - Inability to generate unique usernames within retry limits
 * - Invalid input parameters
 */
public class UsernameGenerationException extends RuntimeException {
    public UsernameGenerationException(String message) {
        super(message);
    }

    public UsernameGenerationException(String message, Throwable cause) {
        super(message, cause);
    }
}
