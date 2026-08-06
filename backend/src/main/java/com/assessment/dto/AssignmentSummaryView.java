package com.assessment.dto;

import java.time.LocalDateTime;

/**
 * Row for the assignment-modules (modul penugasan) table: one per
 * {@code TestAssignment}, enriched with how many results have come in for the
 * tests it carries plus the latest generated credential PDF batch.
 */
public record AssignmentSummaryView(
        Long id,
        String schoolName,
        String categoryName,
        String[] tests,
        boolean active,
        LocalDateTime windowStart,
        LocalDateTime windowEnd,
        long resultCount,
        Long latestBatchId,
        String latestBatchFilename) {
}
