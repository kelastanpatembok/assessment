package com.assessment.controller;

import com.assessment.exception.ConflictException;
import com.assessment.exception.ResourceNotFoundException;
import com.assessment.model.AssessmentUser;
import com.assessment.model.IstMePair;
import com.assessment.model.IstQuestion;
import com.assessment.model.IstResult;
import com.assessment.model.IstWuQuestion;
import com.assessment.model.IstZrQuestion;
import com.assessment.repository.AssessmentUserRepository;
import com.assessment.repository.IstMePairRepository;
import com.assessment.repository.IstQuestionRepository;
import com.assessment.repository.IstResultRepository;
import com.assessment.repository.IstWuQuestionRepository;
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
    private final IstWuQuestionRepository istWuQuestionRepository;
    private final IstMePairRepository istMePairRepository;
    private final IstResultRepository istResultRepository;
    private final AssessmentUserRepository assessmentUserRepository;
    private final IstScoringService istScoringService;
    private final TestAssignmentService testAssignmentService;
    private final ActivityLogService activityLogService;

    record SubmitRequest(Long assignmentId, List<IstSubtestAnswers> subtests) {}

    /**
     * Returns questions for one subtest at a time via ?subtest=SE|WA|AN|GE|RA|ZR|FA|WU|ME.
     * ME pairs hide the correctAnswer field — callers should discard it client-side;
     * the scoring service uses the DB value directly.
     */
    @GetMapping("/questions")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<?> questions(@RequestParam(required = false) String subtest) {
        if (subtest == null || subtest.isBlank()) {
            return ResponseEntity.ok(istQuestionRepository.findAll());
        }
        return switch (subtest.toUpperCase()) {
            case "ZR" -> ResponseEntity.ok(istZrQuestionRepository.findAllByOrderByItemNoAsc());
            case "WU" -> ResponseEntity.ok(istWuQuestionRepository.findAllByOrderByItemNoAsc());
            case "ME" -> {
                List<IstMePair> pairs = istMePairRepository.findAllByOrderByItemNoAsc();
                // Mask correct answer before sending to client
                List<Map<String, Object>> masked = pairs.stream().map(p -> {
                    Map<String, Object> m = new java.util.LinkedHashMap<>();
                    m.put("id", p.getId());
                    m.put("itemNo", p.getItemNo());
                    m.put("word1", p.getWord1());
                    m.put("word2", p.getWord2());
                    m.put("options", p.getOptions());
                    return m;
                }).toList();
                yield ResponseEntity.ok(masked);
            }
            default -> ResponseEntity.ok(
                    istQuestionRepository.findBySubtestCodeAndActiveTrueOrderByItemNoAsc(subtest.toUpperCase()));
        };
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
