package com.assessment.controller;

import com.assessment.model.AssessmentUser;
import com.assessment.repository.AssessmentUserRepository;
import com.assessment.security.CurrentUser;
import com.assessment.service.ProfileService;
import com.assessment.service.StudentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/students")
@RequiredArgsConstructor
public class StudentController {

    private final StudentService studentService;
    private final ProfileService profileService;
    private final AssessmentUserRepository userRepository;

    record CreateStudentRequest(String username, String email, String password,
                                String name, Long schoolId, String afiliatorId, Long categoryId) {}

    record CreateCounselorRequest(String username, String email, String password,
                                  String name, Long schoolId) {}

    record CreateAfiliatorRequest(String username, String email, String password, String name) {}

    @GetMapping
    @PreAuthorize("hasAnyRole('SUPERADMIN','GURUBK','AFILIATOR')")
    public ResponseEntity<List<AssessmentUser>> listStudents() {
        String role = CurrentUser.role();
        String userId = CurrentUser.userId();
        if ("superadmin".equals(role)) {
            return ResponseEntity.ok(profileService.getAllByRole("siswa"));
        } else if ("gurubk".equals(role)) {
            AssessmentUser counselor = profileService.getProfile(userId);
            Long schoolId = counselor.getSchool() != null ? counselor.getSchool().getId() : null;
            if (schoolId == null) return ResponseEntity.ok(List.of());
            return ResponseEntity.ok(
                profileService.getAllBySchool(schoolId).stream()
                    .filter(u -> "siswa".equals(u.getRole())).toList()
            );
        } else {
            return ResponseEntity.ok(profileService.getAllByAfiliator(userId));
        }
    }

    @GetMapping("/{authUserId}")
    @PreAuthorize("hasAnyRole('SUPERADMIN','GURUBK','AFILIATOR')")
    public ResponseEntity<AssessmentUser> getStudent(@PathVariable String authUserId) {
        return ResponseEntity.ok(profileService.getProfile(authUserId));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('SUPERADMIN','GURUBK','AFILIATOR')")
    public ResponseEntity<AssessmentUser> createStudent(@RequestBody CreateStudentRequest req) {
        String role = CurrentUser.role();
        String userId = CurrentUser.userId();
        Long schoolId = req.schoolId();
        String afiliatorId = req.afiliatorId();
        if ("gurubk".equals(role)) {
            AssessmentUser counselor = profileService.getProfile(userId);
            schoolId = counselor.getSchool() != null ? counselor.getSchool().getId() : schoolId;
        } else if ("afiliator".equals(role)) {
            afiliatorId = userId;
        }
        AssessmentUser user = studentService.createStudent(
                req.username(), req.email(), req.password(),
                req.name(), schoolId, afiliatorId, req.categoryId());
        return ResponseEntity.ok(user);
    }

    @DeleteMapping("/{authUserId}")
    @PreAuthorize("hasAnyRole('SUPERADMIN','GURUBK','AFILIATOR')")
    public ResponseEntity<Void> deleteStudent(@PathVariable String authUserId) {
        userRepository.deleteById(authUserId);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/counselor")
    @PreAuthorize("hasRole('SUPERADMIN')")
    public ResponseEntity<AssessmentUser> createCounselor(@RequestBody CreateCounselorRequest req) {
        AssessmentUser user = studentService.createCounselor(
                req.username(), req.email(), req.password(), req.name(), req.schoolId());
        return ResponseEntity.ok(user);
    }

    @PostMapping("/afiliator")
    @PreAuthorize("hasRole('SUPERADMIN')")
    public ResponseEntity<AssessmentUser> createAfiliator(@RequestBody CreateAfiliatorRequest req) {
        AssessmentUser user = studentService.createAfiliator(
                req.username(), req.email(), req.password(), req.name());
        return ResponseEntity.ok(user);
    }
}
