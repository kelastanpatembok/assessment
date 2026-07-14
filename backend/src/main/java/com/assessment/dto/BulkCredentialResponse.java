package com.assessment.dto;

import java.time.LocalDateTime;
import java.util.List;

public record BulkCredentialResponse(
    List<CredentialDTO> credentials,
    String schoolName,
    String testCategory,
    int count,
    String createdBy,
    LocalDateTime createdAt,
    Long credentialBatchId // null if the server-side PDF export failed to save
) {}
