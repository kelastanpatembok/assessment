package com.assessment.controller;

import com.assessment.model.FeeConfig;
import com.assessment.model.FeeShare;
import com.assessment.security.CurrentUser;
import com.assessment.service.FeeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
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
    public ResponseEntity<List<FeeShare>> my() {
        String role = CurrentUser.role();
        String userId = CurrentUser.userId();
        List<FeeShare> shares = "afiliator".equalsIgnoreCase(role)
                ? feeService.getSharesForAfiliator(userId)
                : feeService.getSharesForStudent(userId);
        return ResponseEntity.ok(shares);
    }

    @GetMapping("/summary/afiliator")
    @PreAuthorize("hasRole('AFILIATOR')")
    public ResponseEntity<Map<String, Object>> afiliatorSummary() {
        BigDecimal total = feeService.getTotalShareForAfiliator(CurrentUser.userId());
        return ResponseEntity.ok(Map.of("totalShare", total));
    }
}
