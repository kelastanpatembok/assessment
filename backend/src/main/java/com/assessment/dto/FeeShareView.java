package com.assessment.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Enriched fee-share row for the commission reports: joins the student profile
 * (name + school) and the test category name onto the raw {@code FeeShare}
 * so the UI can render a human-readable table without extra lookups.
 */
public record FeeShareView(
        Long id,
        String studentName,
        String schoolName,
        String categoryName,
        BigDecimal totalFee,
        BigDecimal afiliatorShare,
        BigDecimal gurubkShare,
        BigDecimal platformShare,
        LocalDateTime createdAt) {
}
