package com.assessment.common;

import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;

import java.util.Arrays;
import java.util.List;

/**
 * Shared pagination / sorting query-parameter handling for list endpoints.
 *
 * Every list endpoint accepts the same optional parameters:
 *   page  — zero-based page number (default 0)
 *   size  — rows per page, clamped to [1, 100] (default 10)
 *   search — case-insensitive LIKE across the endpoint's searchable fields
 *   sort  — column key (must be in the endpoint's whitelist)
 *   order — asc | desc (default asc)
 *
 * When {@code page} and {@code size} are both absent the endpoint returns the
 * legacy plain list, keeping old consumers working unchanged.
 */
public final class Paging {

    public static final int DEFAULT_SIZE = 10;
    public static final int MAX_SIZE = 100;

    private Paging() {}

    public static int page(Integer page) {
        return page == null || page < 0 ? 0 : page;
    }

    public static int size(Integer size) {
        if (size == null || size < 1) return DEFAULT_SIZE;
        return Math.min(size, MAX_SIZE);
    }

    /** True when the caller asked for a paginated response. */
    public static boolean paginated(Integer page, Integer size) {
        return page != null || size != null;
    }

    public static Pageable pageable(Integer page, Integer size, String sort, String order,
                                    String defaultSort, String... allowedSorts) {
        return PageRequest.of(page(page), size(size), buildSort(sort, order, defaultSort, allowedSorts));
    }

    /**
     * Builds a {@link Sort} from a requested field, falling back to the default
     * field when the requested one is missing or not in the whitelist.
     */
    public static Sort buildSort(String sort, String order, String defaultSort, String... allowedSorts) {
        List<String> allowed = allowedSorts == null ? List.of() : Arrays.asList(allowedSorts);
        String field = (sort == null || sort.isBlank()) ? defaultSort : sort;
        if (!allowed.contains(field)) field = defaultSort;
        if (field == null || field.isBlank()) return Sort.unsorted();
        boolean asc = !"desc".equalsIgnoreCase(order);
        return Sort.by(asc ? Sort.Direction.ASC : Sort.Direction.DESC, field);
    }
}
