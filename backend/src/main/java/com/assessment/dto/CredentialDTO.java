package com.assessment.dto;

import java.time.LocalDateTime;

public record CredentialDTO(
    String username,
    String password, // plaintext (never logged or stored)
    String authUserId,
    LocalDateTime createdAt
) {}
