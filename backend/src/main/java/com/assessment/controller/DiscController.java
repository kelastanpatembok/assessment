package com.assessment.controller;

import com.assessment.exception.ConflictException;
import com.assessment.exception.ResourceNotFoundException;
import com.assessment.model.AssessmentUser;
import com.assessment.model.DiscQuestion;
import com.assessment.model.DiscResult;
import com.assessment.repository.AssessmentUserRepository;
import com.assessment.repository.DiscQuestionRepository;
import com.assessment.repository.DiscResultRepository;
import com.assessment.security.CurrentUser;
import com.assessment.service.ActivityLogService;
import com.assessment.service.DiscScoringService;
import com.assessment.service.DiscScoringService.DiscAnswerDto;
import com.assessment.service.TestAssignmentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/disc")
@RequiredArgsConstructor
public class DiscController {

    private final DiscQuestionRepository discQuestionRepository;
    private final DiscResultRepository discResultRepository;
    private final AssessmentUserRepository assessmentUserRepository;
    private final DiscScoringService discScoringService;
    private final TestAssignmentService testAssignmentService;
    private final ActivityLogService activityLogService;

    record SubmitRequest(Long assignmentId, List<DiscAnswerDto> answers) {}

    @GetMapping("/questions")
    @PreAuthorize("hasRole('SISWA')")
    public ResponseEntity<List<DiscQuestion>> questions() {
        String userId = CurrentUser.userId();
        AssessmentUser user = assessmentUserRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));
        Long schoolId = user.getSchool() != null ? user.getSchool().getId() : null;
        testAssignmentService.requireAccess(userId, schoolId, "disc");
        return ResponseEntity.ok(discQuestionRepository.findByActiveTrueOrderByBlockNoAscItemNoAsc());
    }

    @GetMapping("/check")
    @PreAuthorize("hasRole('SISWA')")
    public ResponseEntity<Map<String, Object>> check() {
        String userId = CurrentUser.userId();
        AssessmentUser user = assessmentUserRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));
        Long schoolId = user.getSchool() != null ? user.getSchool().getId() : null;
        boolean completed = discResultRepository.findByAuthUserId(userId).isPresent();
        boolean canTake = !completed && schoolId != null && testAssignmentService.checkAccess(userId, schoolId, "disc");
        Long assignmentId = canTake
                ? testAssignmentService.getActiveAssignmentId(userId, schoolId, "disc")
                : null;
        var assignment = testAssignmentService.findAssignmentForType(userId, schoolId, "disc");
        Map<String, Object> body = new java.util.HashMap<>();
        body.put("canTake", canTake);
        body.put("completed", completed);
        body.put("assignmentId", assignmentId != null ? assignmentId : 0L);
        body.put("windowStart", assignment != null ? assignment.getWindowStart() : null);
        body.put("windowEnd", assignment != null ? assignment.getWindowEnd() : null);
        return ResponseEntity.ok(body);
    }

    @PostMapping("/submit")
    @PreAuthorize("hasRole('SISWA')")
    public ResponseEntity<DiscResult> submit(@RequestBody SubmitRequest req) {
        String userId = CurrentUser.userId();
        if (discResultRepository.findByAuthUserId(userId).isPresent()) {
            throw new ConflictException("Tes DISC sudah pernah dikerjakan");
        }
        AssessmentUser user = assessmentUserRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));
        Long schoolId = user.getSchool() != null ? user.getSchool().getId() : null;
        testAssignmentService.requireAccess(userId, schoolId, "disc");
        String studentName = user.getName();
        String schoolName = user.getSchool() != null ? user.getSchool().getName() : "";
        activityLogService.logEvent(userId, "disc", "START", Map.of());
        DiscResult result = discScoringService.scoreAndSave(userId, studentName, schoolName,
                req.assignmentId(), req.answers());
        activityLogService.logEvent(userId, "disc", "FINISH", Map.of("resultId", result.getId()));
        return ResponseEntity.ok(result);
    }

    @GetMapping("/result/me")
    @PreAuthorize("hasRole('SISWA')")
    public ResponseEntity<DiscResult> myResult() {
        DiscResult result = discResultRepository.findByAuthUserId(CurrentUser.userId())
                .orElseThrow(() -> new ResourceNotFoundException("No DISC result found"));
        return ResponseEntity.ok(result);
    }

    @GetMapping("/results")
    @PreAuthorize("hasAnyRole('SUPERADMIN','GURUBK','AFILIATOR','PSIKOLOG')")
    public ResponseEntity<List<DiscResult>> allResults() {
        return ResponseEntity.ok(discResultRepository.findAll());
    }

    @GetMapping("/results/{authUserId}")
    @PreAuthorize("hasAnyRole('SUPERADMIN','GURUBK','AFILIATOR','PSIKOLOG')")
    public ResponseEntity<DiscResult> resultForStudent(@PathVariable String authUserId) {
        DiscResult result = discResultRepository.findByAuthUserId(authUserId)
                .orElseThrow(() -> new ResourceNotFoundException("No DISC result found for: " + authUserId));
        return ResponseEntity.ok(result);
    }
}
