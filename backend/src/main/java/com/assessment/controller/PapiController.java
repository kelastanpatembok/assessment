package com.assessment.controller;

import com.assessment.exception.ResourceNotFoundException;
import com.assessment.model.AssessmentUser;
import com.assessment.model.PapiQuestion;
import com.assessment.model.PapiResult;
import com.assessment.repository.AssessmentUserRepository;
import com.assessment.repository.PapiQuestionRepository;
import com.assessment.repository.PapiResultRepository;
import com.assessment.security.CurrentUser;
import com.assessment.service.ActivityLogService;
import com.assessment.service.PapiScoringService;
import com.assessment.service.PapiScoringService.PapiAnswerDto;
import com.assessment.service.TestAssignmentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/papi")
@RequiredArgsConstructor
public class PapiController {

    private final PapiQuestionRepository papiQuestionRepository;
    private final PapiResultRepository papiResultRepository;
    private final AssessmentUserRepository assessmentUserRepository;
    private final PapiScoringService papiScoringService;
    private final TestAssignmentService testAssignmentService;
    private final ActivityLogService activityLogService;

    record SubmitRequest(Long assignmentId, List<PapiAnswerDto> answers) {}

    @GetMapping("/questions")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<List<PapiQuestion>> questions() {
        return ResponseEntity.ok(papiQuestionRepository.findByActiveTrueOrderByPairNoAscItemLetterAsc());
    }

    @GetMapping("/check")
    @PreAuthorize("hasRole('SISWA')")
    public ResponseEntity<Map<String, Object>> check() {
        String userId = CurrentUser.userId();
        AssessmentUser user = assessmentUserRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));
        Long schoolId = user.getSchool() != null ? user.getSchool().getId() : null;
        boolean canTake = schoolId != null && testAssignmentService.checkAccess(userId, schoolId, "papi");
        Long assignmentId = canTake
                ? testAssignmentService.getActiveAssignmentId(userId, schoolId, "papi")
                : null;
        return ResponseEntity.ok(Map.of("canTake", canTake, "assignmentId", assignmentId != null ? assignmentId : 0L));
    }

    @PostMapping("/submit")
    @PreAuthorize("hasRole('SISWA')")
    public ResponseEntity<PapiResult> submit(@RequestBody SubmitRequest req) {
        String userId = CurrentUser.userId();
        AssessmentUser user = assessmentUserRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));
        String studentName = user.getName();
        String schoolName = user.getSchool() != null ? user.getSchool().getName() : "";
        activityLogService.logEvent(userId, "papi", "START", Map.of());
        PapiResult result = papiScoringService.scoreAndSave(userId, studentName, schoolName,
                req.assignmentId(), req.answers());
        activityLogService.logEvent(userId, "papi", "FINISH", Map.of("resultId", result.getId()));
        return ResponseEntity.ok(result);
    }

    @GetMapping("/result/me")
    @PreAuthorize("hasRole('SISWA')")
    public ResponseEntity<PapiResult> myResult() {
        PapiResult result = papiResultRepository.findByAuthUserId(CurrentUser.userId())
                .orElseThrow(() -> new ResourceNotFoundException("No PAPI result found"));
        return ResponseEntity.ok(result);
    }

    @GetMapping("/results")
    @PreAuthorize("hasAnyRole('SUPERADMIN','GURUBK','AFILIATOR')")
    public ResponseEntity<List<PapiResult>> allResults() {
        return ResponseEntity.ok(papiResultRepository.findAll());
    }

    @GetMapping("/results/{authUserId}")
    @PreAuthorize("hasAnyRole('SUPERADMIN','GURUBK','AFILIATOR')")
    public ResponseEntity<PapiResult> resultForStudent(@PathVariable String authUserId) {
        PapiResult result = papiResultRepository.findByAuthUserId(authUserId)
                .orElseThrow(() -> new ResourceNotFoundException("No PAPI result found for: " + authUserId));
        return ResponseEntity.ok(result);
    }
}
