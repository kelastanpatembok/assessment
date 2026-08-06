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
@RequestMapping("/users")
@RequiredArgsConstructor
public class UserController {

    private final ProfileService profileService;
    private final StudentService studentService;
    private final AssessmentUserRepository userRepository;

    record CreateUserRequest(String username, String email, String password, String name,
                              String role, Long schoolId) {}

    record UpdateUserRequest(String name, String email, Long schoolId, String password) {}

    @GetMapping
    @PreAuthorize("hasRole('SUPERADMIN')")
    public ResponseEntity<?> listAll(
            @RequestParam(required = false) Integer page,
            @RequestParam(required = false) Integer size,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String sort,
            @RequestParam(required = false) String order,
            @RequestParam(required = false) String role) {
        Specification<AssessmentUser> spec = Specs.<AssessmentUser>all()
                .and(Specs.like(search, "name", "username", "email"))
                .and(Specs.eq("role", role));
        if (Paging.paginated(page, size)) {
            Page<AssessmentUser> result = userRepository.findAll(spec,
                    Paging.pageable(page, size, sort, order, "createdAt",
                            "name", "username", "email", "role", "school.name", "createdAt"));
            return ResponseEntity.ok(PageResponse.from(result));
        }
        return ResponseEntity.ok(userRepository.findAll());
    }

    @GetMapping("/me")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<AssessmentUser> me() {
        return ResponseEntity.ok(profileService.getProfile(CurrentUser.userId()));
    }

    @PostMapping
    @PreAuthorize("hasRole('SUPERADMIN')")
    public ResponseEntity<AssessmentUser> create(@RequestBody CreateUserRequest req) {
        AssessmentUser user = switch (req.role()) {
            case "gurubk" -> studentService.createCounselor(req.username(), req.email(), req.password(), req.name(), req.schoolId());
            case "afiliator" -> studentService.createAfiliator(req.username(), req.email(), req.password(), req.name());
            case "psikolog" -> studentService.createPsikolog(req.username(), req.email(), req.password(), req.name());
            default -> throw new IllegalArgumentException("Use /students for siswa role");
        };
        return ResponseEntity.ok(user);
    }

    @PutMapping("/{authUserId}")
    @PreAuthorize("hasRole('SUPERADMIN')")
    public ResponseEntity<AssessmentUser> update(@PathVariable String authUserId,
                                                  @RequestBody UpdateUserRequest req) {
        return ResponseEntity.ok(profileService.updateUser(authUserId, req.name(), req.email(), req.schoolId(), req.password()));
    }

    @DeleteMapping("/{authUserId}")
    @PreAuthorize("hasRole('SUPERADMIN')")
    public ResponseEntity<Void> delete(@PathVariable String authUserId) {
        userRepository.deleteById(authUserId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/role/{role}")
    @PreAuthorize("hasAnyRole('SUPERADMIN','GURUBK')")
    public ResponseEntity<List<AssessmentUser>> byRole(@PathVariable String role) {
        return ResponseEntity.ok(profileService.getAllByRole(role));
    }

    @GetMapping("/school/{schoolId}")
    @PreAuthorize("hasAnyRole('SUPERADMIN','GURUBK')")
    public ResponseEntity<List<AssessmentUser>> bySchool(@PathVariable Long schoolId) {
        return ResponseEntity.ok(profileService.getAllBySchool(schoolId));
    }
}
