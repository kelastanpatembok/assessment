package com.assessment.controller;

import com.assessment.common.Paging;
import com.assessment.common.Specs;
import com.assessment.dto.AssignmentSummaryView;
import com.assessment.dto.PageResponse;
import com.assessment.model.CredentialBatch;
import com.assessment.model.TestAssignment;
import com.assessment.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.stream.Collectors;

/**
 * Server-side paged source for the "Modul Penugasan" admin table. The legacy
 * implementation fetched every assignment plus every result collection and did
 * search/filter/sort/paging in the browser; this endpoint moves that work to
 * the database while keeping the same row shape.
 */
@RestController
@RequestMapping("/assignment-summaries")
@RequiredArgsConstructor
public class AssignmentModuleController {

    private final TestAssignmentRepository assignmentRepository;
    private final DiscResultRepository discResultRepository;
    private final HollandResultRepository hollandResultRepository;
    private final PapiResultRepository papiResultRepository;
    private final CfitResultRepository cfitResultRepository;
    private final IstResultRepository istResultRepository;
    private final CredentialBatchRepository credentialBatchRepository;

    @GetMapping
    @PreAuthorize("hasAnyRole('SUPERADMIN','GURUBK')")
    public ResponseEntity<?> list(
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer size,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String sort,
            @RequestParam(required = false) String order,
            @RequestParam(required = false) Boolean active) {
        Specification<TestAssignment> spec = Specs.<TestAssignment>all()
                .and(Specs.like(search, "school.name", "category.name"))
                .and(Specs.eq("active", active));
        Page<TestAssignment> result = assignmentRepository.findAll(spec,
                Paging.pageable(page, size, sort, order, "windowStart",
                        "id", "school.name", "category.name", "windowStart", "windowEnd"));

        List<Long> ids = result.getContent().stream().map(TestAssignment::getId).toList();
        Map<Long, Long> resultCounts = countResultsPerAssignment(ids);
        Map<Long, CredentialBatch> latestBatches = latestBatchPerAssignment(ids);

        List<AssignmentSummaryView> items = result.getContent().stream()
                .map(a -> toView(a, resultCounts, latestBatches))
                .toList();
        return ResponseEntity.ok(PageResponse.of(items, result.getNumber(), result.getSize(), result.getTotalElements()));
    }

    /** Aggregates for the header cards (total / active / results across ALL assignments). */
    @GetMapping("/summary")
    @PreAuthorize("hasAnyRole('SUPERADMIN','GURUBK')")
    public ResponseEntity<Map<String, Object>> summary() {
        List<TestAssignment> all = assignmentRepository.findAll();
        Set<Long> ids = all.stream().map(TestAssignment::getId).collect(Collectors.toSet());
        long totalResults = ids.isEmpty() ? 0 : countResultsPerAssignment(ids).values().stream().mapToLong(Long::longValue).sum();
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("totalAssignments", all.size());
        body.put("activeAssignments", all.stream().filter(TestAssignment::isActive).count());
        body.put("totalResults", totalResults);
        return ResponseEntity.ok(body);
    }

    private AssignmentSummaryView toView(TestAssignment a, Map<Long, Long> counts, Map<Long, CredentialBatch> latestBatches) {
        CredentialBatch latest = latestBatches.get(a.getId());
        return new AssignmentSummaryView(
                a.getId(),
                a.getSchool() != null ? a.getSchool().getName() : "-",
                a.getCategory() != null ? a.getCategory().getName() : "-",
                a.getCategory() != null ? a.getCategory().getTests() : new String[0],
                a.isActive(),
                a.getWindowStart(),
                a.getWindowEnd(),
                counts.getOrDefault(a.getId(), 0L),
                latest != null ? latest.getId() : null,
                latest != null ? latest.getPdfFilename() : null);
    }

    /** Counts results grouped by assignmentId across all five instrument tables. */
    private Map<Long, Long> countResultsPerAssignment(Collection<Long> ids) {
        if (ids == null || ids.isEmpty()) return Map.of();
        Map<Long, Long> counts = new HashMap<>();
        for (Long id : ids) counts.put(id, 0L);
        countInto(discResultRepository.findByAssignmentIdIn(ids), counts);
        countInto(hollandResultRepository.findByAssignmentIdIn(ids), counts);
        countInto(papiResultRepository.findByAssignmentIdIn(ids), counts);
        countInto(cfitResultRepository.findByAssignmentIdIn(ids), counts);
        countInto(istResultRepository.findByAssignmentIdIn(ids), counts);
        return counts;
    }

    private void countInto(List<? extends com.assessment.model.HasAssignmentId> results, Map<Long, Long> counts) {
        for (var r : results) {
            if (r.getAssignmentId() != null) {
                counts.merge(r.getAssignmentId(), 1L, Long::sum);
            }
        }
    }

    private Map<Long, CredentialBatch> latestBatchPerAssignment(Collection<Long> ids) {
        if (ids == null || ids.isEmpty()) return Map.of();
        Map<Long, CredentialBatch> latest = new HashMap<>();
        for (Long id : ids) {
            credentialBatchRepository.findFirstByTestAssignmentIdOrderByCreatedAtDesc(id)
                    .ifPresent(b -> latest.put(id, b));
        }
        return latest;
    }
}
