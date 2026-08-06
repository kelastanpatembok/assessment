package com.assessment.controller;

import com.assessment.common.Paging;
import com.assessment.common.Specs;
import com.assessment.dto.PageResponse;
import com.assessment.model.TestAssignment;
import com.assessment.repository.TestAssignmentRepository;
import com.assessment.security.CurrentUser;
import com.assessment.service.TestAssignmentService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequiredArgsConstructor
public class TestAssignmentController {

    private final TestAssignmentService testAssignmentService;
    private final TestAssignmentRepository testAssignmentRepository;

    record CreateAssignmentRequest(Long categoryId, Long schoolId, String studentId,
                                   String startDate, String endDate,
                                   boolean certificateEnabled) {}

    record UpdateAssignmentRequest(String startDate, String endDate,
                                   Boolean active, Boolean certificateEnabled) {}

    @GetMapping({"/assignments", "/test-assignments"})
    @PreAuthorize("hasAnyRole('SUPERADMIN','GURUBK')")
    public ResponseEntity<?> listAll(
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer size,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String sort,
            @RequestParam(required = false) String order,
            @RequestParam(required = false) Boolean active) {
        Specification<TestAssignment> spec = Specs.<TestAssignment>all()
                .and(Specs.like(search, "school.name", "category.name"))
                .and(Specs.eq("active", active));
        if (Paging.paginated(page, size)) {
            Page<TestAssignment> result = testAssignmentRepository.findAll(spec,
                    Paging.pageable(page, size, sort, order, "windowStart",
                            "school.name", "category.name", "windowStart", "windowEnd", "id", "createdAt"));
            return ResponseEntity.ok(PageResponse.from(result));
        }
        return ResponseEntity.ok(testAssignmentService.getAll());
    }

    @PostMapping({"/assignments", "/test-assignments"})
    @PreAuthorize("hasAnyRole('SUPERADMIN','GURUBK')")
    public ResponseEntity<TestAssignment> create(@RequestBody CreateAssignmentRequest req) {
        LocalDateTime windowStart = req.startDate() != null
                ? LocalDateTime.parse(req.startDate() + "T00:00:00") : null;
        LocalDateTime windowEnd = req.endDate() != null
                ? LocalDateTime.parse(req.endDate() + "T23:59:59") : null;
        TestAssignment assignment = testAssignmentService.createAssignment(
                req.categoryId(), req.schoolId(), req.studentId(),
                CurrentUser.userId(), windowStart, windowEnd);
        return ResponseEntity.ok(assignment);
    }

    @GetMapping({"/assignments/school/{schoolId}", "/test-assignments/school/{schoolId}"})
    @PreAuthorize("hasAnyRole('SUPERADMIN','GURUBK')")
    public ResponseEntity<List<TestAssignment>> bySchool(@PathVariable Long schoolId) {
        return ResponseEntity.ok(testAssignmentService.getForSchool(schoolId));
    }

    @GetMapping({"/assignments/student/{studentId}", "/test-assignments/student/{studentId}"})
    @PreAuthorize("hasAnyRole('SUPERADMIN','GURUBK')")
    public ResponseEntity<List<TestAssignment>> byStudent(@PathVariable String studentId) {
        return ResponseEntity.ok(testAssignmentService.getForStudent(studentId));
    }

    @GetMapping({"/assignments/my", "/test-assignments/my"})
    @PreAuthorize("hasRole('SISWA')")
    public ResponseEntity<List<TestAssignment>> my() {
        return ResponseEntity.ok(testAssignmentService.getForStudent(CurrentUser.userId()));
    }

    @PutMapping({"/assignments/{id}", "/test-assignments/{id}"})
    @PreAuthorize("hasAnyRole('SUPERADMIN','GURUBK')")
    public ResponseEntity<TestAssignment> update(@PathVariable Long id, @RequestBody UpdateAssignmentRequest req) {
        TestAssignment assignment = testAssignmentService.getById(id);
        if (req.startDate() != null) assignment.setWindowStart(LocalDateTime.parse(req.startDate() + "T00:00:00"));
        if (req.endDate() != null) assignment.setWindowEnd(LocalDateTime.parse(req.endDate() + "T23:59:59"));
        if (req.active() != null) assignment.setActive(req.active());
        return ResponseEntity.ok(testAssignmentService.save(assignment));
    }

    @DeleteMapping({"/assignments/{id}", "/test-assignments/{id}"})
    @PreAuthorize("hasAnyRole('SUPERADMIN','GURUBK')")
    public ResponseEntity<Void> deactivate(@PathVariable Long id) {
        testAssignmentService.deactivate(id);
        return ResponseEntity.noContent().build();
    }
}
