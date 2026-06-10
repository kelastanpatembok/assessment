package com.assessment.controller;

import com.assessment.exception.ResourceNotFoundException;
import com.assessment.model.AssessmentUser;
import com.assessment.model.CfitQuestion;
import com.assessment.model.CfitResult;
import com.assessment.repository.AssessmentUserRepository;
import com.assessment.repository.CfitQuestionRepository;
import com.assessment.repository.CfitResultRepository;
import com.assessment.security.CurrentUser;
import com.assessment.service.ActivityLogService;
import com.assessment.service.CfitScoringService;
import com.assessment.service.CfitScoringService.CfitAnswerDto;
import com.assessment.service.TestAssignmentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/cfit")
@RequiredArgsConstructor
public class CfitController {

    private final CfitQuestionRepository cfitQuestionRepository;
    private final CfitResultRepository cfitResultRepository;
    private final AssessmentUserRepository assessmentUserRepository;
    private final CfitScoringService cfitScoringService;
    private final TestAssignmentService testAssignmentService;
    private final ActivityLogService activityLogService;

    record SubmitRequest(Long assignmentId, List<CfitAnswerDto> answers) {}

    @GetMapping("/questions")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<List<CfitQuestion>> questions() {
        return ResponseEntity.ok(cfitQuestionRepository.findByActiveTrueOrderBySubtestNoAscItemNoAsc());
    }

    @GetMapping("/check")
    @PreAuthorize("hasRole('SISWA')")
    public ResponseEntity<Map<String, Object>> check() {
        String userId = CurrentUser.userId();
        AssessmentUser user = assessmentUserRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));
        Long schoolId = user.getSchool() != null ? user.getSchool().getId() : null;
        boolean canTake = schoolId != null && testAssignmentService.checkAccess(userId, schoolId, "cfit");
        Long assignmentId = canTake
                ? testAssignmentService.getActiveAssignmentId(userId, schoolId, "cfit")
                : null;
        return ResponseEntity.ok(Map.of("canTake", canTake, "assignmentId", assignmentId != null ? assignmentId : 0L));
    }

    @PostMapping("/submit")
    @PreAuthorize("hasRole('SISWA')")
    public ResponseEntity<CfitResult> submit(@RequestBody SubmitRequest req) {
        String userId = CurrentUser.userId();
        AssessmentUser user = assessmentUserRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));
        String studentName = user.getName();
        String schoolName = user.getSchool() != null ? user.getSchool().getName() : "";
        activityLogService.logEvent(userId, "cfit", "START", Map.of());
        CfitResult result = cfitScoringService.scoreAndSave(userId, studentName, schoolName,
                req.assignmentId(), req.answers());
        activityLogService.logEvent(userId, "cfit", "FINISH", Map.of("resultId", result.getId()));
        return ResponseEntity.ok(result);
    }

    @GetMapping("/result/me")
    @PreAuthorize("hasRole('SISWA')")
    public ResponseEntity<CfitResult> myResult() {
        CfitResult result = cfitResultRepository.findByAuthUserId(CurrentUser.userId())
                .orElseThrow(() -> new ResourceNotFoundException("No CFIT result found"));
        return ResponseEntity.ok(result);
    }

    @GetMapping("/results")
    @PreAuthorize("hasAnyRole('SUPERADMIN','GURUBK','AFILIATOR')")
    public ResponseEntity<List<CfitResult>> allResults() {
        return ResponseEntity.ok(cfitResultRepository.findAll());
    }

    @GetMapping("/results/{authUserId}")
    @PreAuthorize("hasAnyRole('SUPERADMIN','GURUBK','AFILIATOR')")
    public ResponseEntity<CfitResult> resultForStudent(@PathVariable String authUserId) {
        CfitResult result = cfitResultRepository.findByAuthUserId(authUserId)
                .orElseThrow(() -> new ResourceNotFoundException("No CFIT result found for: " + authUserId));
        return ResponseEntity.ok(result);
    }
}
