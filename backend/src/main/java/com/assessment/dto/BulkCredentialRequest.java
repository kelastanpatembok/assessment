package com.assessment.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record BulkCredentialRequest(
    @NotNull Long testAssignmentId,
    @NotBlank @Size(max = 10) @Pattern(regexp = "^[A-Za-z0-9_]+$") String schoolCode,
    @NotBlank @Size(max = 10) @Pattern(regexp = "^[A-Za-z0-9_]+$") String testCode,
    @Min(1) @Max(500) int count
) {}
