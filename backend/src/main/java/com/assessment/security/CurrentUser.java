package com.assessment.security;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

/**
 * Convenience helper to extract authenticated user details from SecurityContext.
 */
public final class CurrentUser {

    private CurrentUser() {}

    private static JwtAuthenticationDetails details() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.getDetails() instanceof JwtAuthenticationDetails d) {
            return d;
        }
        throw new IllegalStateException("No authenticated user in context");
    }

    public static String userId() {
        return details().getUserId();
    }

    public static String username() {
        return details().getUsername();
    }

    public static String role() {
        return details().getRole();
    }
}
