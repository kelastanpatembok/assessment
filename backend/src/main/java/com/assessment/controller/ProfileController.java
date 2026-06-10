package com.assessment.controller;

import com.assessment.exception.ResourceNotFoundException;
import com.assessment.model.AssessmentUser;
import com.assessment.security.CurrentUser;
import com.assessment.service.ProfileService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/profile")
@RequiredArgsConstructor
public class ProfileController {

    private final ProfileService profileService;

    record ProvisionRequest(String name, String email, String username, String role) {}

    @PostMapping("/provision")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<AssessmentUser> provision(@RequestBody ProvisionRequest req) {
        AssessmentUser user = profileService.provisionProfile(
                CurrentUser.userId(), req.name(), req.email(), req.username(), req.role());
        return ResponseEntity.ok(user);
    }

    @GetMapping("/me")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<AssessmentUser> me() {
        AssessmentUser user = profileService.getProfile(CurrentUser.userId());
        return ResponseEntity.ok(user);
    }
}
