package com.assessment.controller;

import com.assessment.common.Paging;
import com.assessment.dto.FeeShareView;
import com.assessment.dto.PageResponse;
import com.assessment.model.FeeConfig;
import com.assessment.security.CurrentUser;
import com.assessment.service.FeeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.Comparator;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/fees")
@RequiredArgsConstructor
public class FeeController {

    private final FeeService feeService;

    record FeeConfigRequest(Long categoryId, BigDecimal studentFee,
                            BigDecimal afiliatorSharePct, BigDecimal gurubkSharePct,
                            BigDecimal platformSharePct) {}

    @GetMapping("/config")
    @PreAuthorize("hasRole('SUPERADMIN')")
    public ResponseEntity<List<FeeConfig>> allConfigs() {
        return ResponseEntity.ok(feeService.getAllConfigs());
    }

    @PutMapping("/config")
    @PreAuthorize("hasRole('SUPERADMIN')")
    public ResponseEntity<FeeConfig> upsertConfig(@RequestBody FeeConfigRequest req) {
        FeeConfig config = feeService.updateConfig(
                req.categoryId(), req.studentFee(),
                req.afiliatorSharePct(), req.gurubkSharePct(), req.platformSharePct());
        return ResponseEntity.ok(config);
    }

    @GetMapping("/my")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<?> my(
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer size,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String sort,
            @RequestParam(required = false) String order) {
        String role = CurrentUser.role();
        String userId = CurrentUser.userId();
        List<FeeShareView> rows = "afiliator".equalsIgnoreCase(role)
                ? feeService.getShareViewsForAfiliator(userId)
                : feeService.getShareViewsForStudent(userId);

        if (search != null && !search.isBlank()) {
            String q = search.trim().toLowerCase();
            rows = rows.stream()
                    .filter(v -> contains(v.studentName(), q)
                            || contains(v.schoolName(), q)
                            || contains(v.categoryName(), q))
                    .toList();
        }

        Comparator<FeeShareView> cmp = switch (sort == null ? "" : sort) {
            case "studentName" -> Comparator.comparing(FeeShareView::studentName,
                    Comparator.nullsLast(String.CASE_INSENSITIVE_ORDER));
            case "categoryName" -> Comparator.comparing(FeeShareView::categoryName,
                    Comparator.nullsLast(String.CASE_INSENSITIVE_ORDER));
            case "afiliatorShare" -> Comparator.comparing(FeeShareView::afiliatorShare,
                    Comparator.nullsLast(Comparator.naturalOrder()));
            case "createdAt" -> Comparator.comparing(FeeShareView::createdAt,
                    Comparator.nullsLast(Comparator.naturalOrder()));
            default -> Comparator.comparing(FeeShareView::createdAt,
                    Comparator.nullsLast(Comparator.naturalOrder()));
        };
        if (!"asc".equalsIgnoreCase(order)) cmp = cmp.reversed();

        if (Paging.paginated(page, size)) {
            List<FeeShareView> sorted = rows.stream().sorted(cmp).toList();
            int p = Paging.page(page);
            int s = Paging.size(size);
            int from = Math.min(p * s, sorted.size());
            int to = Math.min(from + s, sorted.size());
            return ResponseEntity.ok(PageResponse.of(sorted.subList(from, to), p, s, sorted.size()));
        }
        return ResponseEntity.ok(rows.stream().sorted(cmp).toList());
    }

    private static boolean contains(String value, String q) {
        return value != null && value.toLowerCase().contains(q);
    }

    @GetMapping("/summary/afiliator")
    @PreAuthorize("hasRole('AFILIATOR')")
    public ResponseEntity<Map<String, Object>> afiliatorSummary() {
        BigDecimal total = feeService.getTotalShareForAfiliator(CurrentUser.userId());
        return ResponseEntity.ok(Map.of("totalShare", total));
    }
}
