package com.assessment.controller;

import com.assessment.dto.DashboardDTO;
import com.assessment.model.AssessmentUser;
import com.assessment.security.CurrentUser;
import com.assessment.service.DashboardService;
import com.assessment.service.ProfileService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/dashboard")
@RequiredArgsConstructor
public class DashboardController {

    private final DashboardService dashboardService;
    private final ProfileService profileService;

    @GetMapping("/summary")
    @PreAuthorize("hasAnyRole('SUPERADMIN','GURUBK')")
    public ResponseEntity<DashboardDTO> getDashboardSummary() {
        String role = CurrentUser.role();
        String userId = CurrentUser.userId();
        
        Long schoolId = null;
        if ("gurubk".equals(role)) {
            AssessmentUser counselor = profileService.getProfile(userId);
            if (counselor.getSchool() != null) {
                schoolId = counselor.getSchool().getId();
            }
        }
        
        if (schoolId == null) {
            return ResponseEntity.ok(new DashboardDTO(0, 0, 0.0, java.util.Map.of(), java.util.Map.of()));
        }
        
        return ResponseEntity.ok(dashboardService.getDashboardSummaryForSchool(schoolId));
    }
}
