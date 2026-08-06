package com.assessment.common;

import jakarta.persistence.criteria.Path;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import org.springframework.data.jpa.domain.Specification;

import java.util.Arrays;

/**
 * Small helpers for building Spring Data {@link Specification} predicates
 * used by the shared server-side table query parameters.
 *
 * Dot notation ("school.name") is resolved through nested paths so joined
 * attributes can be searched/sorted the same way as plain columns.
 */
public final class Specs {

    private Specs() {}

    /** No-op predicate; combine with {@code and(...)} to build up filters. */
    public static <T> Specification<T> all() {
        return (root, cq, cb) -> cb.conjunction();
    }

    private static Path<?> path(Root<?> root, String dottedField) {
        String[] parts = dottedField.split("\\.");
        Path<?> p = root.get(parts[0]);
        for (int i = 1; i < parts.length; i++) p = p.get(parts[i]);
        return p;
    }

    /** Case-insensitive LIKE across several (possibly dotted) string fields. */
    public static <T> Specification<T> like(String query, String... fields) {
        return (root, cq, cb) -> {
            if (query == null || query.isBlank()) return cb.conjunction();
            String like = "%" + query.trim().toLowerCase() + "%";
            Predicate[] preds = Arrays.stream(fields)
                    .map(f -> cb.like(cb.lower(path(root, f).as(String.class)), like))
                    .toArray(Predicate[]::new);
            return cb.or(preds);
        };
    }

    /** Equality on a (possibly dotted) attribute; skipped when value is null. */
    public static <T> Specification<T> eq(String dottedField, Object value) {
        return (root, cq, cb) -> {
            if (value == null) return cb.conjunction();
            return cb.equal(path(root, dottedField), value);
        };
    }
}
