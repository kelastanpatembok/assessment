package com.assessment.controller;

import com.assessment.exception.ResourceNotFoundException;
import com.assessment.model.AssessmentUser;
import com.assessment.model.HollandQuestion;
import com.assessment.model.HollandResult;
import com.assessment.repository.AssessmentUserRepository;
import com.assessment.repository.HollandQuestionRepository;
import com.assessment.repository.HollandResultRepository;
import com.assessment.security.CurrentUser;
import com.assessment.service.ActivityLogService;
import com.assessment.service.HollandScoringService;
import com.assessment.service.HollandScoringService.HollandAnswerDto;
import com.assessment.service.TestAssignmentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/holland")
@RequiredArgsConstructor
public class HollandController {

    private final HollandQuestionRepository hollandQuestionRepository;
    private final HollandResultRepository hollandResultRepository;
    private final AssessmentUserRepository assessmentUserRepository;
    private final HollandScoringService hollandScoringService;
    private final TestAssignmentService testAssignmentService;
    private final ActivityLogService activityLogService;

    record SubmitRequest(Long assignmentId, List<HollandAnswerDto> answers) {}

    @GetMapping("/questions")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<List<HollandQuestion>> questions() {
        return ResponseEntity.ok(hollandQuestionRepository.findByActiveTrueOrderByGroupCodeAscItemNoAsc());
    }

    @GetMapping("/check")
    @PreAuthorize("hasRole('SISWA')")
    public ResponseEntity<Map<String, Object>> check() {
        String userId = CurrentUser.userId();
        AssessmentUser user = assessmentUserRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));
        Long schoolId = user.getSchool() != null ? user.getSchool().getId() : null;
        boolean canTake = schoolId != null && testAssignmentService.checkAccess(userId, schoolId, "holland");
        Long assignmentId = canTake
                ? testAssignmentService.getActiveAssignmentId(userId, schoolId, "holland")
                : null;
        return ResponseEntity.ok(Map.of("canTake", canTake, "assignmentId", assignmentId != null ? assignmentId : 0L));
    }

    @PostMapping("/submit")
    @PreAuthorize("hasRole('SISWA')")
    public ResponseEntity<HollandResult> submit(@RequestBody SubmitRequest req) {
        String userId = CurrentUser.userId();
        AssessmentUser user = assessmentUserRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));
        String studentName = user.getName();
        String schoolName = user.getSchool() != null ? user.getSchool().getName() : "";
        activityLogService.logEvent(userId, "holland", "START", Map.of());
        HollandResult result = hollandScoringService.scoreAndSave(userId, studentName, schoolName,
                req.assignmentId(), req.answers());
        activityLogService.logEvent(userId, "holland", "FINISH", Map.of("resultId", result.getId()));
        return ResponseEntity.ok(result);
    }

    @GetMapping("/result/me")
    @PreAuthorize("hasRole('SISWA')")
    public ResponseEntity<HollandResult> myResult() {
        HollandResult result = hollandResultRepository.findByAuthUserId(CurrentUser.userId())
                .orElseThrow(() -> new ResourceNotFoundException("No Holland result found"));
        return ResponseEntity.ok(result);
    }

    @GetMapping("/results")
    @PreAuthorize("hasAnyRole('SUPERADMIN','GURUBK','AFILIATOR')")
    public ResponseEntity<List<HollandResult>> allResults() {
        return ResponseEntity.ok(hollandResultRepository.findAll());
    }

    @GetMapping("/results/{authUserId}")
    @PreAuthorize("hasAnyRole('SUPERADMIN','GURUBK','AFILIATOR')")
    public ResponseEntity<HollandResult> resultForStudent(@PathVariable String authUserId) {
        HollandResult result = hollandResultRepository.findByAuthUserId(authUserId)
                .orElseThrow(() -> new ResourceNotFoundException("No Holland result found for: " + authUserId));
        return ResponseEntity.ok(result);
    }
}
