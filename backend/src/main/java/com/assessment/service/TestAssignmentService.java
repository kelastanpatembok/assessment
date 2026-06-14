package com.assessment.service;

import com.assessment.exception.ResourceNotFoundException;
import com.assessment.model.AssessmentUser;
import com.assessment.model.School;
import com.assessment.model.TestAssignment;
import com.assessment.model.TestCategory;
import com.assessment.repository.AssessmentUserRepository;
import com.assessment.repository.SchoolRepository;
import com.assessment.repository.TestAssignmentRepository;
import com.assessment.repository.TestCategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;

@Service
@RequiredArgsConstructor
public class TestAssignmentService {

    private final TestAssignmentRepository testAssignmentRepository;
    private final TestCategoryRepository testCategoryRepository;
    private final AssessmentUserRepository assessmentUserRepository;
    private final SchoolRepository schoolRepository;

    @Transactional
    public TestAssignment createAssignment(Long categoryId, Long schoolId, String studentId,
                                           String assignedBy, LocalDateTime windowStart,
                                           LocalDateTime windowEnd) {
        TestCategory category = testCategoryRepository.findById(categoryId)
                .orElseThrow(() -> new ResourceNotFoundException("TestCategory not found: " + categoryId));

        School school = null;
        if (schoolId != null) {
            school = schoolRepository.findById(schoolId)
                    .orElseThrow(() -> new ResourceNotFoundException("School not found: " + schoolId));
        }

        AssessmentUser student = null;
        if (studentId != null) {
            student = assessmentUserRepository.findById(studentId)
                    .orElseThrow(() -> new ResourceNotFoundException("Student not found: " + studentId));
        }

        TestAssignment assignment = TestAssignment.builder()
                .category(category)
                .school(school)
                .student(student)
                .assignedBy(assignedBy)
                .windowStart(windowStart)
                .windowEnd(windowEnd)
                .active(true)
                .build();
        return testAssignmentRepository.save(assignment);
    }

    @Transactional(readOnly = true)
    public List<TestAssignment> getAll() {
        return testAssignmentRepository.findAll();
    }

    @Transactional(readOnly = true)
    public TestAssignment getById(Long id) {
        return testAssignmentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("TestAssignment not found: " + id));
    }

    @Transactional(readOnly = true)
    public List<TestAssignment> getForSchool(Long schoolId) {
        return testAssignmentRepository.findBySchoolId(schoolId);
    }

    @Transactional(readOnly = true)
    public List<TestAssignment> getForStudent(String studentId) {
        return testAssignmentRepository.findByStudentAuthUserId(studentId);
    }

    @Transactional(readOnly = true)
    public Long getActiveAssignmentId(String authUserId, Long schoolId, String testType) {
        return testAssignmentRepository
                .findActiveForStudent(schoolId, authUserId, LocalDateTime.now()).stream()
                .filter(a -> {
                    String[] tests = a.getCategory().getTests();
                    return tests != null && java.util.Arrays.asList(tests).contains(testType);
                })
                .map(TestAssignment::getId)
                .findFirst().orElse(null);
    }

    @Transactional(readOnly = true)
    public boolean checkAccess(String authUserId, Long schoolId, String testType) {
        List<TestAssignment> active = testAssignmentRepository
                .findActiveForStudent(schoolId, authUserId, LocalDateTime.now());
        return active.stream().anyMatch(a -> {
            String[] tests = a.getCategory().getTests();
            return tests != null && Arrays.asList(tests).contains(testType);
        });
    }

    @Transactional
    public TestAssignment save(TestAssignment assignment) {
        return testAssignmentRepository.save(assignment);
    }

    @Transactional
    public void deactivate(Long id) {
        TestAssignment assignment = getById(id);
        assignment.setActive(false);
        testAssignmentRepository.save(assignment);
    }
}
