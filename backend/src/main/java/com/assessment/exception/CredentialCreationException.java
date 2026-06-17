package com.assessment.exception;

/**
 * Exception thrown when credential creation fails during atomic transaction.
 * 
 * This exception is used to indicate failures in the transaction coordination
 * process across auth service (MongoDB) and assessment database (PostgreSQL).
 */
public class CredentialCreationException extends RuntimeException {
    public CredentialCreationException(String message) {
        super(message);
    }

    public CredentialCreationException(String message, Throwable cause) {
        super(message, cause);
    }
}
