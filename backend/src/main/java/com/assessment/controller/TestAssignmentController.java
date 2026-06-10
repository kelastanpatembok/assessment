package com.assessment.controller;

import com.assessment.model.TestAssignment;
import com.assessment.security.CurrentUser;
import com.assessment.service.TestAssignmentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequiredArgsConstructor
public class TestAssignmentController {

    private final TestAssignmentService testAssignmentService;

    record CreateAssignmentRequest(Long categoryId, Long schoolId, String studentId,
                                   String startDate, String endDate,
                                   boolean certificateEnabled) {}

    @GetMapping({"/assignments", "/test-assignments"})
    @PreAuthorize("hasAnyRole('SUPERADMIN','GURUBK')")
    public ResponseEntity<List<TestAssignment>> listAll() {
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

    @DeleteMapping({"/assignments/{id}", "/test-assignments/{id}"})
    @PreAuthorize("hasAnyRole('SUPERADMIN','GURUBK')")
    public ResponseEntity<Void> deactivate(@PathVariable Long id) {
        testAssignmentService.deactivate(id);
        return ResponseEntity.noContent().build();
    }
}
