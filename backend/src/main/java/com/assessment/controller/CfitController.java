package com.assessment.controller;

import com.assessment.exception.ConflictException;
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

    // Student-facing question shape — deliberately excludes correctAnswer/correctAnswer2
    // so the answer key isn't shipped to the browser (the legacy app leaked it into the
    // exam page's HTML source; see docs/todo-cfit-test.md).
    record CfitQuestionView(Long id, Integer subtestNo, Integer itemNo, String stemImageUrl, List<String> optionImages) {}

    @GetMapping("/questions")
    @PreAuthorize("hasRole('SISWA')")
    public ResponseEntity<List<CfitQuestionView>> questions() {
        String userId = CurrentUser.userId();
        AssessmentUser user = assessmentUserRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));
        Long schoolId = user.getSchool() != null ? user.getSchool().getId() : null;
        testAssignmentService.requireAccess(userId, schoolId, "cfit");
        List<CfitQuestionView> views = cfitQuestionRepository.findByActiveTrueOrderBySubtestNoAscItemNoAsc()
                .stream()
                .map(q -> new CfitQuestionView(q.getId(), q.getSubtestNo(), q.getItemNo(), q.getStemImageUrl(), q.getOptionImages()))
                .toList();
        return ResponseEntity.ok(views);
    }

    @GetMapping("/check")
    @PreAuthorize("hasRole('SISWA')")
    public ResponseEntity<Map<String, Object>> check() {
        String userId = CurrentUser.userId();
        AssessmentUser user = assessmentUserRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));
        Long schoolId = user.getSchool() != null ? user.getSchool().getId() : null;
        boolean completed = cfitResultRepository.findByAuthUserId(userId).isPresent();
        boolean canTake = !completed && schoolId != null && testAssignmentService.checkAccess(userId, schoolId, "cfit");
        Long assignmentId = canTake
                ? testAssignmentService.getActiveAssignmentId(userId, schoolId, "cfit")
                : null;
        var assignment = testAssignmentService.findAssignmentForType(userId, schoolId, "cfit");
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
    public ResponseEntity<CfitResult> submit(@RequestBody SubmitRequest req) {
        String userId = CurrentUser.userId();
        if (cfitResultRepository.findByAuthUserId(userId).isPresent()) {
            throw new ConflictException("Tes CFIT sudah pernah dikerjakan");
        }
        AssessmentUser user = assessmentUserRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));
        Long schoolId = user.getSchool() != null ? user.getSchool().getId() : null;
        testAssignmentService.requireAccess(userId, schoolId, "cfit");
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
