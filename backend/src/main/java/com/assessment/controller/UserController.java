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
    public ResponseEntity<List<AssessmentUser>> listAll() {
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
