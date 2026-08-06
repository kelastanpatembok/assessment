package com.assessment.dto;

import org.springframework.data.domain.Page;

import java.util.List;

/**
 * Standard paginated envelope returned by list endpoints when page/size
 * request parameters are present. When they are absent the same endpoints
 * keep returning the legacy plain list, so existing consumers are unaffected.
 *
 * @param items         rows for the requested page
 * @param page          zero-based page number
 * @param size          page size (rows per page)
 * @param totalElements total number of matching rows across all pages
 * @param totalPages    total number of pages
 */
public record PageResponse<T>(
        List<T> items,
        int page,
        int size,
        long totalElements,
        int totalPages) {

    public static <T> PageResponse<T> from(Page<T> page) {
        return new PageResponse<>(
                page.getContent(),
                page.getNumber(),
                page.getSize(),
                page.getTotalElements(),
                page.getTotalPages());
    }

    public static <T> PageResponse<T> of(List<T> items, int page, int size, long totalElements) {
        int totalPages = size <= 0 ? 0 : (int) Math.ceil((double) totalElements / size);
        return new PageResponse<>(items, page, size, totalElements, totalPages);
    }

    public static <T> PageResponse<T> empty() {
        return new PageResponse<>(List.of(), 0, 0, 0, 0);
    }
}
