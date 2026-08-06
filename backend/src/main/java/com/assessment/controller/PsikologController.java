package com.assessment.controller;

import com.assessment.common.Paging;
import com.assessment.common.Specs;
import com.assessment.dto.PageResponse;
import com.assessment.model.AssessmentUser;
import com.assessment.repository.AssessmentUserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.jpa.domain.Specification;
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
    public ResponseEntity<?> search(@RequestParam String query,
                                    @RequestParam(required = false) Integer page,
                                    @RequestParam(required = false) Integer size,
                                    @RequestParam(required = false) String sort,
                                    @RequestParam(required = false) String order) {
        String q = query == null ? "" : query.trim();
        if (q.length() < 2) {
            return ResponseEntity.ok(Paging.paginated(page, size)
                    ? PageResponse.of(List.of(), Paging.page(page), Paging.size(size), 0)
                    : List.of());
        }
        if (Paging.paginated(page, size)) {
            Specification<AssessmentUser> spec = Specs.<AssessmentUser>all()
                    .and(Specs.eq("role", "siswa"))
                    .and(Specs.like(q, "username", "name"));
            Page<AssessmentUser> result = userRepository.findAll(spec,
                    Paging.pageable(page, size, sort, order, "name", "name", "username", "createdAt"));
            return ResponseEntity.ok(PageResponse.from(result));
        }
        return ResponseEntity.ok(userRepository
                .findTop50ByUsernameContainingIgnoreCaseOrNameContainingIgnoreCase(q, q));
    }
}
