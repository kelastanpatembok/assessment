package com.assessment.controller;

import com.assessment.common.Paging;
import com.assessment.common.Specs;
import com.assessment.dto.PageResponse;
import com.assessment.exception.ConflictException;
import com.assessment.exception.ResourceNotFoundException;
import com.assessment.model.AssessmentUser;
import com.assessment.model.PapiQuestion;
import com.assessment.model.PapiResult;
import com.assessment.repository.AssessmentUserRepository;
import com.assessment.repository.PapiQuestionRepository;
import com.assessment.repository.PapiResultRepository;
import com.assessment.security.CurrentUser;
import com.assessment.service.ActivityLogService;
import com.assessment.service.PapiInterpretationService;
import com.assessment.service.PapiInterpretationService.TraitDetail;
import com.assessment.service.PapiScoringService;
import com.assessment.service.PapiScoringService.PapiAnswerDto;
import com.assessment.service.TestAssignmentService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
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
    private final PapiInterpretationService papiInterpretationService;
    private final TestAssignmentService testAssignmentService;
    private final ActivityLogService activityLogService;

    record SubmitRequest(Long assignmentId, List<PapiAnswerDto> answers) {}

    record PapiResultView(Long id, String authUserId, String studentName, String schoolName,
                           Long assignmentId, String traitScores, List<TraitDetail> traitDetails,
                           LocalDateTime completedAt) {}

    private PapiResultView toView(PapiResult result) {
        return new PapiResultView(
                result.getId(), result.getAuthUserId(), result.getStudentName(), result.getSchoolName(),
                result.getAssignmentId(), result.getTraitScores(), papiInterpretationService.interpret(result),
                result.getCompletedAt());
    }

    @GetMapping("/questions")
    @PreAuthorize("hasRole('SISWA')")
    public ResponseEntity<List<PapiQuestion>> questions() {
        String userId = CurrentUser.userId();
        AssessmentUser user = assessmentUserRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));
        Long schoolId = user.getSchool() != null ? user.getSchool().getId() : null;
        testAssignmentService.requireAccess(userId, schoolId, "papi");
        return ResponseEntity.ok(papiQuestionRepository.findByActiveTrueOrderByPairNoAscItemLetterAsc());
    }

    @GetMapping("/check")
    @PreAuthorize("hasRole('SISWA')")
    public ResponseEntity<Map<String, Object>> check() {
        String userId = CurrentUser.userId();
        AssessmentUser user = assessmentUserRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));
        Long schoolId = user.getSchool() != null ? user.getSchool().getId() : null;
        boolean completed = papiResultRepository.findByAuthUserId(userId).isPresent();
        boolean canTake = !completed && schoolId != null && testAssignmentService.checkAccess(userId, schoolId, "papi");
        Long assignmentId = canTake
                ? testAssignmentService.getActiveAssignmentId(userId, schoolId, "papi")
                : null;
        var assignment = testAssignmentService.findAssignmentForType(userId, schoolId, "papi");
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
    public ResponseEntity<PapiResult> submit(@RequestBody SubmitRequest req) {
        String userId = CurrentUser.userId();
        if (papiResultRepository.findByAuthUserId(userId).isPresent()) {
            throw new ConflictException("Tes PAPI sudah pernah dikerjakan");
        }
        AssessmentUser user = assessmentUserRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + userId));
        Long schoolId = user.getSchool() != null ? user.getSchool().getId() : null;
        testAssignmentService.requireAccess(userId, schoolId, "papi");
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
    public ResponseEntity<PapiResultView> myResult() {
        PapiResult result = papiResultRepository.findByAuthUserId(CurrentUser.userId())
                .orElseThrow(() -> new ResourceNotFoundException("No PAPI result found"));
        return ResponseEntity.ok(toView(result));
    }

    @GetMapping("/results")
    @PreAuthorize("hasAnyRole('SUPERADMIN','GURUBK','AFILIATOR','PSIKOLOG')")
    public ResponseEntity<?> allResults(
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer size,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String sort,
            @RequestParam(required = false) String order) {
        Specification<PapiResult> spec = Specs.like(search, "studentName", "schoolName");
        if (Paging.paginated(page, size)) {
            Page<PapiResult> result = papiResultRepository.findAll(spec,
                    Paging.pageable(page, size, sort, order, "completedAt",
                            "studentName", "schoolName", "completedAt", "id"));
            return ResponseEntity.ok(PageResponse.from(result));
        }
        return ResponseEntity.ok(papiResultRepository.findAll());
    }

    @GetMapping("/results/{authUserId}")
    @PreAuthorize("hasAnyRole('SUPERADMIN','GURUBK','AFILIATOR','PSIKOLOG')")
    public ResponseEntity<PapiResultView> resultForStudent(@PathVariable String authUserId) {
        PapiResult result = papiResultRepository.findByAuthUserId(authUserId)
                .orElseThrow(() -> new ResourceNotFoundException("No PAPI result found for: " + authUserId));
        return ResponseEntity.ok(toView(result));
    }
}
