package com.assessment.controller;

import com.assessment.model.AssessmentUser;
import com.assessment.repository.AssessmentUserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

// Note: the estate gateway routes /api/users/* to the profile service, so
// this panel lives under /api/psikolog/* to reach this backend directly.
@RestController
@RequestMapping("/psikolog")
@RequiredArgsConstructor
public class PsikologController {

    private final AssessmentUserRepository userRepository;

    // Psychologists look up users (by username or name) to review their
    // psychological assessment results during counseling sessions.
    @GetMapping("/search")
    @PreAuthorize("hasAnyRole('SUPERADMIN','PSIKOLOG')")
    public ResponseEntity<List<AssessmentUser>> search(@RequestParam String query) {
        String q = query == null ? "" : query.trim();
        if (q.length() < 2) return ResponseEntity.ok(List.of());
        return ResponseEntity.ok(userRepository
                .findTop50ByUsernameContainingIgnoreCaseOrNameContainingIgnoreCase(q, q));
    }
}
