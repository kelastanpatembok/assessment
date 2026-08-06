package com.assessment.controller;

import com.assessment.common.Paging;
import com.assessment.common.Specs;
import com.assessment.dto.PageResponse;
import com.assessment.model.AssessmentUser;
import com.assessment.repository.AssessmentUserRepository;
import com.assessment.security.CurrentUser;
import com.assessment.service.ProfileService;
import com.assessment.service.StudentService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.jpa.domain.Specification;
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
    @PreAuthorize("hasAnyRole('SUPERADMIN','GURUBK','AFILIATOR','PSIKOLOG')")
    public ResponseEntity<?> listStudents(
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer size,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String sort,
            @RequestParam(required = false) String order) {
        String role = CurrentUser.role();
        String userId = CurrentUser.userId();
        Specification<AssessmentUser> spec = Specs.<AssessmentUser>all()
                .and(Specs.like(search, "name", "username", "email"));
        if ("superadmin".equals(role) || "psikolog".equals(role)) {
            spec = spec.and(Specs.eq("role", "siswa"));
        } else if ("gurubk".equals(role)) {
            AssessmentUser counselor = profileService.getProfile(userId);
            Long schoolId = counselor.getSchool() != null ? counselor.getSchool().getId() : null;
            if (schoolId == null) return ResponseEntity.ok(Paging.paginated(page, size)
                    ? PageResponse.of(List.of(), Paging.page(page), Paging.size(size), 0)
                    : List.of());
            spec = spec.and(Specs.eq("role", "siswa")).and(Specs.eq("school.id", schoolId));
        } else {
            spec = spec.and(Specs.eq("afiliatorId", userId));
        }
        if (Paging.paginated(page, size)) {
            Page<AssessmentUser> result = userRepository.findAll(spec,
                    Paging.pageable(page, size, sort, order, "createdAt",
                            "name", "username", "email", "school.name", "createdAt"));
            return ResponseEntity.ok(PageResponse.from(result));
        }
        return ResponseEntity.ok(userRepository.findAll(spec));
    }

    @GetMapping("/{authUserId}")
    @PreAuthorize("hasAnyRole('SUPERADMIN','GURUBK','AFILIATOR','PSIKOLOG')")
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
