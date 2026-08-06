package com.assessment.model;

/**
 * Marker for result entities that carry a {@code test_assignments} link so the
 * assignment-modules aggregation can count results uniformly.
 */
public interface HasAssignmentId {
    Long getAssignmentId();
}
