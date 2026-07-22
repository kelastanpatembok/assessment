package com.assessment.controller;

import com.assessment.exception.ConflictException;
import com.assessment.exception.ResourceNotFoundException;
import com.assessment.model.AssessmentUser;
import com.assessment.model.IstQuestion;
import com.assessment.model.IstResult;
import com.assessment.model.IstZrQuestion;
import com.assessment.repository.AssessmentUserRepository;
import com.assessment.repository.IstQuestionRepository;
import com.assessment.repository.IstResultRepository;
import com.assessment.repository.IstZrQuestionRepository;
import com.assessment.security.CurrentUser;
import com.assessment.service.ActivityLogService;
import com.assessment.service.IstScoringService;
import com.assessment.service.IstScoringService.IstSubtestAnswers;
import com.assessment.service.TestAssignmentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/ist")
@RequiredArgsConstructor
public class IstController {

    private final IstQuestionRepository istQuestionRepository;
    private final IstZrQuestionRepository istZrQuestionRepository;
    private final IstResultRepository istResultRepository;
    private final AssessmentUserRepository assessmentUserRepository;
    private final IstScoringService istScoringService;
    private final TestAssignmentService testAssignmentService;
    private final ActivityLogService activityLogService;

    record SubmitRequest(Long assignmentId, List<IstSubtestAnswers> subtests) {}

    // Student-facing question shape — deliberately excludes correctAnswer so the answer
    // key isn't shipped to the browser (the legacy app leaked it into the exam page's
    // HTML source; see docs/todo-cfit-test.md / docs/todo-ist-test.md).
    record IstQuestionView(Long id, String subtestCode, Integer itemNo, String questionText,
                            String imageUrl, Map<String, String> options, List<String> optionImages) {}

    // ZR (number sequences) has its own table/repository, so it needs its own masked
    // view — same reasoning as IstQuestionView: don't ship correctAnswer to the client.
    record IstZrQuestionView(Long id, Integer itemNo, String sequenceText) {}

    /**
     * Returns questions for one subtest at a time via ?subtest=SE|WA|AN|GE|RA|ZR|FA|WU|ME.
     * ZR (numeric sequences) has its own table; every other subtest lives in the
     * generic ist_questions table (text MC/free-text for most, image MC for FA/WU).
     */
    @GetMapping("/questions")
    @PreAuthorize("hasRole('SISWA')")
    public ResponseEntity<?> questions(@RequestParam(required = false) String subtest) {
        String userId = CurrentUser.userId();
        AssessmentUser user = assessmentUserRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));
        Long schoolId = user.getSchool() != null ? user.getSchool().getId() : null;
        testAssignmentService.requireAccess(userId, schoolId, "ist");
        if (subtest == null || subtest.isBlank()) {
            return ResponseEntity.ok(toViews(istQuestionRepository.findAll()));
        }
        return switch (subtest.toUpperCase()) {
            case "ZR" -> ResponseEntity.ok(istZrQuestionRepository.findAllByOrderByItemNoAsc().stream()
                    .map(q -> new IstZrQuestionView(q.getId(), q.getItemNo(), q.getSequenceText()))
                    .toList());
            default -> ResponseEntity.ok(toViews(
                    istQuestionRepository.findBySubtestCodeAndActiveTrueOrderByItemNoAsc(subtest.toUpperCase())));
        };
    }

    private List<IstQuestionView> toViews(List<IstQuestion> questions) {
        return questions.stream()
                .map(q -> new IstQuestionView(q.getId(), q.getSubtestCode(), q.getItemNo(), q.getQuestionText(),
                        q.getImageUrl(), q.getOptions(), q.getOptionImages()))
                .toList();
    }

    @GetMapping("/check")
    @PreAuthorize("hasRole('SISWA')")
    public ResponseEntity<Map<String, Object>> check() {
        String userId = CurrentUser.userId();
        AssessmentUser user = assessmentUserRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));
        Long schoolId = user.getSchool() != null ? user.getSchool().getId() : null;
        boolean completed = istResultRepository.findByAuthUserId(userId).isPresent();
        boolean canTake = !completed && schoolId != null && testAssignmentService.checkAccess(userId, schoolId, "ist");
        Long assignmentId = canTake
                ? testAssignmentService.getActiveAssignmentId(userId, schoolId, "ist")
                : null;
        return ResponseEntity.ok(Map.of(
                "canTake", canTake,
                "completed", completed,
                "assignmentId", assignmentId != null ? assignmentId : 0L
        ));
    }

    @PostMapping("/submit")
    @PreAuthorize("hasRole('SISWA')")
    public ResponseEntity<IstResult> submit(@RequestBody SubmitRequest req) {
        String userId = CurrentUser.userId();
        if (istResultRepository.findByAuthUserId(userId).isPresent()) {
            throw new ConflictException("Tes IST sudah pernah dikerjakan");
        }
        AssessmentUser user = assessmentUserRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));
        Long schoolId = user.getSchool() != null ? user.getSchool().getId() : null;
        testAssignmentService.requireAccess(userId, schoolId, "ist");
        String studentName = user.getName();
        String schoolName = user.getSchool() != null ? user.getSchool().getName() : "";
        activityLogService.logEvent(userId, "ist", "START", Map.of());
        IstResult result = istScoringService.scoreAndSave(userId, studentName, schoolName,
                req.assignmentId(), req.subtests());
        activityLogService.logEvent(userId, "ist", "FINISH", Map.of("resultId", result.getId()));
        return ResponseEntity.ok(result);
    }

    @GetMapping("/result/me")
    @PreAuthorize("hasRole('SISWA')")
    public ResponseEntity<IstResult> myResult() {
        IstResult result = istResultRepository.findByAuthUserId(CurrentUser.userId())
                .orElseThrow(() -> new ResourceNotFoundException("No IST result found"));
        return ResponseEntity.ok(result);
    }

    @GetMapping("/results")
    @PreAuthorize("hasAnyRole('SUPERADMIN','GURUBK','AFILIATOR')")
    public ResponseEntity<List<IstResult>> allResults() {
        return ResponseEntity.ok(istResultRepository.findAll());
    }

    @GetMapping("/results/{authUserId}")
    @PreAuthorize("hasAnyRole('SUPERADMIN','GURUBK','AFILIATOR')")
    public ResponseEntity<IstResult> resultForStudent(@PathVariable String authUserId) {
        IstResult result = istResultRepository.findByAuthUserId(authUserId)
                .orElseThrow(() -> new ResourceNotFoundException("No IST result found for: " + authUserId));
        return ResponseEntity.ok(result);
    }
}
